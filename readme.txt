author : sundeepi9@yahoo.in
this will have the vagrant workspace projects across all my systems

RSYNC issues
-------------------------------------------------------------------------------------------------------------START
Check the box synced_folder at C:\Users[username]\.vagrant.d\boxes\centos-VAGRANTSLASH-7\1602.02\virtualbox\Vagrantfile

config.vm.synced_folder ".", "/home/vagrant/sync", type: "rsync"   
Override the defition at project Vagrantfile for directory mapping.

config.vm.synced_folder ".", "/home/vagrant/sync", type: "virtualbox"  
I imagine the box might be prepared at non Windows system, this case can be happened on many boxes, such as fedora/23-cloud-base.


Vagrant was unable to mount VirtualBox shared folders.
----------------------------------------------------	
log on to the virutal box and issue below as root
ln -sf /opt/VBoxGuestAdditions-5.1.20/lib/VBoxGuestAdditions/mount.vboxsf /sbin/mount.vboxsf
