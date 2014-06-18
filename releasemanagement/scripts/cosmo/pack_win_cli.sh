#!/bin/bash

#####################################################################
#install vagrant - https://www.vagrantup.com/downloads.html (1.6.2) #
#vagrant plugin install vagrant-aws (0.4.1)                         #
#vagrant plugin install unf                                         #
#####################################################################

source cli_credentials.sh

rm -f /cloudify/cloudify-cli_*.exe


#destroy windows vm if exit
vagrant destroy -f windows

vagrant up windows --provider=aws

#get guest ip address
ip_address=`vagrant ssh-config | grep HostName | sed "s/HostName//g" | sed "s/ //g"`
echo "ip_address="$ip_address

#copy windows exe file
#scp -i ~/.ssh/aws/vagrant_build.pem ubuntu@$ip_address:~/vagrant/windows/cloudify-cli-packager/packaging/windows/inno/Output/*.exe /cloudify

#vagrant destroy -f windows
