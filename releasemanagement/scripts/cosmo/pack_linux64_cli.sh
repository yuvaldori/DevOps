#!/bin/bash

#####################################################################
#install vagrant - https://www.vagrantup.com/downloads.html (1.6.2) #
#vagrant plugin install vagrant-aws (0.4.1)                         #
#vagrant plugin install unf                                         #
#####################################################################

#source cli_credentials.sh

rm -f /cloudify/cfy_*_amd64.deb


#destroy linux64 vm if exit
vagrant destroy -f linux64

vagrant up linux64 --provider=aws

#get guest ip address
s=`vagrant ssh linux64 -- ec2metadata | grep public-hostname | cut -f1 -d"." | cut -d" " -f2` ; s=${s#ec2-} ; ip_address=${s//-/.}
echo "ip_address="$ip_address

#copy linnux64 deb file
scp -i ~/.ssh/aws/vagrant_build.pem ubuntu@$ip_address:~/cloudify-cli-packager/pyinstaller/*.deb /cloudify

#vagrant destroy -f linux64



