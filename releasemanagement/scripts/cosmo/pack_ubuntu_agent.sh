#!/bin/bash

#####################################################################
#install vagrant - https://www.vagrantup.com/downloads.html (1.6.2) #
#vagrant plugin install vagrant-aws (0.4.1)                         #
#vagrant plugin install unf                                         #
#####################################################################

source ../../../credentials.sh


function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		#vagrant destroy -f centos            
		exit 1
      fi

}

sudo mkdir -p /cloudify
sudo chown tgrid -R /cloudify
rm -f /cloudify/cloudify-ubuntu-agent*


##destroy centos vm if exit
vagrant destroy -f centos

vagrant up centos --provider=aws
exit_on_error

##get guest ip address
ip_address=`vagrant ssh-config centos | grep HostName | sed "s/HostName//g" | sed "s/ //g"`
echo "ip_address="$ip_address

##copy ubuntu deb file
sudo mkdir -p /cloudify
sudo chown tgrid -R /cloudify
scp -i ~/.ssh/aws/vagrant_build.pem root@$ip_address:/cloudify/*.deb /cloudify
exit_on_error

vagrant destroy -f centos
