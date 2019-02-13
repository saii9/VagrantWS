require 'fileutils'
require '../constants'

class Instruct
	def nginx(cluster, boxId, config)
		conf= cluster[boxId]
		boxName = $project + "." + boxId
		config.vm.define boxName do |node|
			node.vm.box = conf[:box]
			node.vm.network "private_network", ip: conf[:ip]
			node.vm.network "forwarded_port", guest: 443, host: 4444 # HTTP
			#node.vm.provision :shell, privileged: true, :path => 'installVboxDrivers.sh'
			#node.vm.provision :shell, privileged: true, :path => 'install-nginx.sh'
			cluster.each_with_index do |(boxId, info), index|					
				node.vm.provision :shell, privileged: true, :path => 'addDNS.sh', :args => [info[:ip], boxId, info[:alias]]
			end
			node.vm.provider :virtualbox do |v|
				v.memory = conf[:mem]
				v.name = boxName
			end
			#node.vm.synced_folder ".", "/var/mount/", :nfs=>true, :disabled=>true
			node.vm.synced_folder ".", "/home/vagrant/sync", disabled: true
			puts boxName + "of the cluster is up"
		end
	end
	
	def appServer(boxId, config)
		conf= cluster[boxId]
		boxName = $project + "." + boxId
		config.vm.define boxName do |node|
			node.vm.box = conf[:box]
			node.vm.network "private_network", ip: conf[:ip]
			node.vm.network "forwarded_port", guest: 443, host: 4444 # HTTP
			#node.vm.provision :shell, privileged: true, :path => 'installVboxDrivers.sh'
			$cluster.each_with_index do |(boxId, info), index|					
				node.vm.provision :shell, privileged: true, :path => 'addDNS.sh', :args => [info[:ip], boxId, info[:alias]]
			end
			node.vm.provider :virtualbox do |v|
				v.memory = conf[:mem]
				v.name = boxName
			end
			#node.vm.synced_folder ".", "/var/mount/", :nfs=>true, :disabled=>true
			node.vm.synced_folder ".", "/home/vagrant/sync", disabled: true
			puts boxName + "of the cluster is up"
		end
	end

	def podbuild(cluster, project, boxId, config)
		conf= cluster[boxId]
		boxName = project + "." + boxId
		config.vm.define boxName do |node|
			node.vm.box = conf[:box]
			node.vm.network "private_network", ip: conf[:ip]
			node.vm.provider :virtualbox do |v|
				v.memory = conf[:mem]
				v.name = boxName
			end
			node.vm.synced_folder ".", "/home/vagrant/sync"
			node.vm.synced_folder "D:\\BSE\\wipod", "/home/vagrant/wipod"
		end
	end

	
	def ansible(cluster, project, boxId, config)
		conf= cluster[boxId]
		boxName = project + "." + boxId
		FileUtils.touch(boxName)
		config.vm.define boxName do |node|
			node.vm.box = conf[:box]
			node.vm.network "private_network", ip: conf[:ip]
			node.vm.provision :shell, privileged: true, :path => 'install.sh'
			cluster.each_with_index do |(boxId, info), index|
				node.vm.provision :shell, privileged: true, path: "../addDNS.sh", :args => [info[:ip], boxId, info[:alias]]
			end
			node.vm.provider :virtualbox do |v|
				v.memory = conf[:mem]
				v.name = boxName
			end
			node.vm.synced_folder Constants::DEPLOY_SCRIPTS_SYNC , "/home/vagrant/deployscripts" #, disabled: true
			node.vm.synced_folder Constants::DEPLOY_SCRIPTS2_SYNC , "/home/vagrant/deployscripts2" #, disabled: true
			node.vm.synced_folder ".", "/home/vagrant/sync" #, disabled: true
		end
	end
	
	def common(cluster, project, boxId, config)
		conf= cluster[boxId]
		boxName = project + "." + boxId
		FileUtils.touch(boxName)
		config.vm.define boxName do |node|
			node.vm.box = conf[:box]
			node.vm.network "private_network", ip: conf[:ip]
			cluster.each_with_index do |(boxId, info), index|
				node.vm.provision :shell, privileged: true, :path => '../addDNS.sh', :args => [info[:ip], boxId, info[:alias]]
			end
			node.vm.provider :virtualbox do |v|
				v.customize ["modifyvm", :id, "--usb", "on"]
				v.customize ["modifyvm", :id, "--usbehci", "on"]

				v.memory = conf[:mem]
				v.name = boxName
			end
			node.vm.synced_folder "D:\\", "/home/vagrant/workspace" #, disabled: true
			node.vm.synced_folder ".", "/home/vagrant/sync" #, disabled: true
			node.vm.provision :shell, privileged: true, :path => 'install.sh'
		end
	end
	
end
