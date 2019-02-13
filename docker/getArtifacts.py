#!/usr/bin/env python

"""
Ask bamboo for the URL to a build artifact.

This turns out not to be entirely straightforward.
There are at least the following flavors to support:

- single build artifacts stored on the bamboo server directly
- multiple build artifacts stored on the bamboo server directly, but
  only available via HTML links not as API data directly
- build artifacts stored on S3, again from HTML links
- build artifacts grouped into several groups, each with its own HTML page,
  then stored on S3
-
"""
from HTMLParser import HTMLParser
import base64
import boto3
import json
import re
import sys
import urllib2
import urlparse
import os
import yaml

class ARGS():
    user = os.environ.get('BAMBOO_USER')
    password = os.environ.get('BAMBOO_PASS')
    project = ""
    branch=""
    match=""
    build=""
    debug=True
    aws_access_key_id="AKIAJYCCHLBOJVTDQZMA"
    aws_secret_access_key="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"
    aws_region="us-east-1"
    save_dir="sharedArtifacts"
    base="https://bamboo.dev.fcawitech.com"

args=ARGS()
debug_messages = []
# create a subclass and override the handler methods
class S3LinkParser(HTMLParser):

    def __init__(self):
        HTMLParser.__init__(self)
        self.urls = []

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            for pair in attrs:
                if pair[0].lower() == "href":
                    if re.search(args.match, pair[1]):
                        self.urls.append(pair[1])


class NoRedirection(urllib2.HTTPErrorProcessor):

    def http_response(self, request, response):
        return response

    https_response = http_response


def exit(message, code=1):
    sys.stderr.write(message + "\n")
    if not args.debug:
        sys.stderr.write("debug messages:\n")
        for debug_message in debug_messages:
            sys.stderr.write(debug_message + "\n")
    sys.exit(code)


def debug(message):
    debug_messages.append(message)
    if not args.debug:
        return
    print(message + "\n")


def add_credentials_to_url(url):
    purl = urlparse.urlparse(url)
    purl = purl._replace(netloc=args.user + ":" + args.password + "@" + purl.netloc)
    return purl.geturl()


def add_credentials(request, user=args.user, password=args.password):
    # You need the replace to handle encodestring adding a trailing newline
    # (https://docs.python.org/2/library/base64.html#base64.encodestring)
    base64string = base64.encodestring(
        "%s:%s" % (user, password)).replace("\n", "")
    request.add_header("Authorization", "Basic %s" % base64string)
    return request


def api_call(suffix):
    url = args.base + "/rest/api/latest" + suffix
    debug("Bamboo API GET: " + url)
    request = urllib2.Request(url)
    add_credentials(request)
    try:
        json_string = urllib2.urlopen(request).read()
    except Exception, info:
        exit("Error calling bamboo API: " + str(info), 10)
    try:
        return json.loads(json_string)
    except Exception, info:
        exit(
            "Invalid JSON in bamboo API response: " + json_string + str(info),
            11)


def get_result():
    if args.branch and "master" != args.branch:
        url = ("/result/{project}/branch/{branch}.json"
               "?expand=results[0].result.artifacts").format(**vars(args))
    else:
        url = ("/result/{project}.json"
               "?expand=results[0].result.artifacts").format(**vars(args))
    res = api_call(url)
    results = res.get("results", {}).get("result", [])
    if not results:
        exit("No build results found: " + json.dumps(res), 12)
    good_build = filter(lambda r: r["buildState"] == "Successful", results)
    if not good_build:
        debug("Could not find good build: " + json.dumps(results))
        exit("No successful build found in most recent build", 13)
    return good_build[0]


def get_artifacts(result):
    url = ("/result/{buildResultKey}.json?"
           "expand=stages.stage.results.result.artifacts").format(**result)
    # @bug dev/test s3 build
    # url = "/result/PRJVOD-PLNVOD1-389.json?expand=stages.stage.results.result.artifacts"
    res = api_call(url)
    first_stage = res.get("stages", {}).get("stage", [])[0] or {}
    first_result = first_stage.get("results", {}).get("result", [])[0] or {}
    artifacts = first_result.get("artifacts", {}).get("artifact", [])
    debug("Loaded artifacts from bamboo: " + json.dumps(artifacts, indent=2))
    return artifacts


# http://stackoverflow.com/a/11744894
def parse_artifact_links(url_to_html):
    debug("parse_artifact_links GET " + url_to_html)
    request = urllib2.Request(url_to_html)
    add_credentials(request)
    opener = urllib2.build_opener(NoRedirection)
    try:
      response = opener.open(request)
    except Exception, info:
      exit("Error getting artifact list HTML page: " + str(info), 14)

    redirect = response.headers.get("Location")
    if redirect:
        if re.search(args.match, redirect):
            return redirect
        else:
            return None

    html = response.read()
    debug("artifact list HTML: " + html)
    parser = S3LinkParser()
    parser.feed(html)
    if not parser.urls:
        return
    debug("artifact URLs: " + str(parser.urls))
    #if len(parser.urls) > 1:
    #    exit("Multiple matching build artifacts found." +
    #         " Tighten up your build match regex please.", 18)
    #url = parser.urls[0]
    for url in parser.urls:
        if url.startswith("/"):
            url = args.base + url
        if url.lower().startswith(args.base.lower()):
            url = add_credentials_to_url(url)
    return parser.urls


def resign_url(original_url):
    debug("original_url: " + original_url)
    boto3_session = boto3.Session(
        aws_access_key_id=args.aws_access_key_id,
        aws_secret_access_key=args.aws_secret_access_key,
        region_name=args.aws_region)
    client = boto3_session.client(
	service_name="s3",
	endpoint_url="https://s3-accelerate.amazonaws.com")
    bucket = re.sub(r"http.://","",re.sub(r".s3.amazonaws.com/.*","",original_url))
    key = re.sub(r"\?.*","",re.sub(r".*amazonaws.com/","",original_url))
    resigned_url = client.generate_presigned_url( "get_object", Params = {"Bucket": bucket, "Key": key } )
    debug("resigned_url: " + resigned_url)
    return resigned_url


def get_s3_urls():
    if args.build.startswith(args.project):
        artifacts = get_artifacts({"buildResultKey": args.build})
    else:
        result = get_result()
        artifacts = get_artifacts(result)
    urls = map(lambda a: a.get("link", {}).get("href"), artifacts)
    debug("Parsed artifact urls: " + json.dumps(urls))
    #multiartifact_urls = filter(lambda h: re.search("/$", h), urls)
    #bamboo_urls = filter(lambda h: re.search(args.match, h), urls)
    #if bamboo_urls:
    #    if len(bamboo_urls) > 1:
    #        exit("Multiple matching build artifacts found." +
    #             " Tighten up your build match regex please.", 17)
    #    print(add_credentials_to_url(bamboo_urls[0]))
    #    return
    s3_redirects = filter(
        lambda h: re.search("artifactUrlRedirect\.action", h), urls)
    s3_urls = []
    for url in s3_redirects:
        s3_url = parse_artifact_links(url)
        if s3_url:
            s3_urls.extend(s3_url) if type(s3_url) is list else s3_urls.append(s3_url)
    debug("S3 URLs: " + str(s3_urls))
    #if len(s3_urls) > 1:
    #    exit("Multiple matching s3 redirect URLs found." +
    #         " Tighten up your build match regex please.", 17)
    if s3_urls:
        if args.aws_access_key_id:
            for u in s3_urls :
                u=resign_url(u)
        return s3_urls
    #elif multiartifact_urls:
    #    parse_artifact_links(multiartifact_urls[0])
    else:
        exit("No artifact URL matched regex", 16)


def downloadS3Urls(url):
    if not os.path.exists(args.save_dir): os.mkdir(args.save_dir)
    response = urllib2.urlopen(url)
    if response.code != 200: exit("Cannot download a artifact ", 21)
    filename = re.findall("filename=\"(.+)\"", response.headers.get("content-disposition"))
    if len(filename) == 0: exit("Cannot find the file name form content disposition", 21)
    f = open(args.save_dir +"/"+ filename[0], 'wb')
    f.write(response.read())
    debug("saved to file "+ args.save_dir +"/"+ filename[0])

if __name__ == "__main__":
    manifest=None
    cbranch=os.environ.get("BAMBOO_BRANCH")
    temp = ARGS()
    with open(os.environ.get("manifest"), 'r') as stream:
        try:
            manifest=yaml.load(stream)
        except yaml.YAMLError as exc:
            exit("cannot get tp parse the manifest", 23)

    for k,v  in manifest.items():
        debug("downloading project" + k)
        debug("branch config" + str(v))

        if cbranch in v.get("branchMap"): temp.branch = v.get("branchMap").get(cbranch)
        elif "default" in v.get("branchMap"):
            if "default" == v.get("branchMap").get("default"): temp.branch = cbranch
            else: temp.branch= v.get("branchMap").get("default")
        else: exit("Cannot find matching branch configuration")

        debug("getting Artifact from " + str(temp.branch))
        #temp.branch = v.get("branchMap").get(cbranch)
        temp.match  = v.get("match")
        temp.project = v.get("planKey")
        temp.save_dir = v.get("saveDir")
        args=temp
        for url in get_s3_urls():
           downloadS3Urls(url)

