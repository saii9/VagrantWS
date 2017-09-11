author : sundeepi9@yahoo.in
this will have the vagrant workspace projects across all my systems

RSYNC issues
-------------------------------------------------------------------------------------------------------------START
Check the box synced_folder at C:\Users[username]\.vagrant.d\boxes\centos-VAGRANTSLASH-7\1602.02\virtualbox\Vagrantfile

config.vm.synced_folder ".", "/home/vagrant/sync", type: "rsync"   
Override the defition at project Vagrantfile for directory mapping.

config.vm.synced_folder ".", "/home/vagrant/sync", type: "virtualbox"  
I imagine the box might be prepared at non Windows system, this case can be happened on many boxes, such as fedora/23-cloud-base.

The VirtualBox Guest Additions are not preinstalled; if you need them for shared folders, please install the vagrant-vbguest plugin and add the following line to your Vagrantfile:
config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
We recommend using NFS instead of VirtualBox shared folders if possible; you can also use the vagrant-sshfs plugin, which, unlike NFS, works on all operating systems.

Since the Guest Additions are missing, our images are preconfigured to use rsync for synced folders. Windows users can either use SMB for synced folders, or disable the sync directory by adding the line
config.vm.synced_folder ".", "/vagrant", disabled: true
to their Vagrantfile, to prevent errors on "vagrant up".



Vagrant was unable to mount VirtualBox shared folders.
----------------------------------------------------	
log on to the virutal box and issue below as root
ln -sf /opt/VBoxGuestAdditions-5.1.20/lib/VBoxGuestAdditions/mount.vboxsf /sbin/mount.vboxsf

add a vagrant box
----------------------------------------------------