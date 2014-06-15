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
s=`vagrant ssh windows -- ec2metadata | grep public-hostname | cut -f1 -d"." | cut -d" " -f2` ; s=${s#ec2-} ; ip_address=${s//-/.}
echo "ip_address="$ip_address

#copy windows exe file
#scp -i ~/.ssh/aws/vagrant_build.pem ubuntu@$ip_address:~/vagrant/windows/cloudify-cli-packager/packaging/windows/inno/Output/*.exe /cloudify

#vagrant destroy -f windows
