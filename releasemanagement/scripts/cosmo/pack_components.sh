#!/bin/bash

#####################################################################
#install vagrant - https://www.vagrantup.com/downloads.html (1.6.2) #
#vagrant plugin install vagrant-aws (0.4.1)                         #
#vagrant plugin install unf                                         #
#####################################################################

source ../../../cli_credentials.sh

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		vagrant destroy -f
		exit 1
      fi

}

rm -f /cloudify/cloudify-components*_amd64.deb


#destroy vm if exit
vagrant destroy -f

vagrant up --provider=aws
exit_on_error

#get guest ip address
s=`vagrant ssh -- ec2metadata | grep public-hostname | cut -f1 -d"." | cut -d" " -f2` ; s=${s#ec2-} ; ip_address=${s//-/.}
echo "ip_address="$ip_address

#copy components deb file
sudo mkdir -p /cloudify
sudo chown tgrid -R /cloudify
scp -i ~/.ssh/aws/vagrant_build.pem ubuntu@$ip_address:/cloudify-packager/output-packages/*.deb /cloudify
exit_on_error

vagrant destroy -f
