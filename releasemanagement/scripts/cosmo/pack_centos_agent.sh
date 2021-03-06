#!/bin/bash

#####################################################################
#install vagrant - https://www.vagrantup.com/downloads.html (1.6.2) #
#vagrant plugin install vagrant-aws (0.4.1)                         #
#vagrant plugin install unf                                         #
#####################################################################

source ../../../credentials.sh
source /etc/environment

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		vagrant destroy -f centos_final_aws            
		exit 1
      fi

}

sudo mkdir -p /cloudify
sudo chown tgrid -R /cloudify
rm -f /cloudify/cloudify-centos-agent*


##destroy vm if exit
vagrant destroy -f centos_final_aws

vagrant up centos_final_aws --provider=aws
exit_on_error

##get guest ip address
ip_address=`vagrant ssh-config centos_final_aws | grep HostName | sed "s/HostName//g" | sed "s/ //g"`
echo "ip_address="$ip_address

##copy deb file
sudo mkdir -p /cloudify
sudo chown tgrid -R /cloudify
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/.ssh/aws/vagrant_centos_build.pem root@$ip_address:/cloudify/*.deb /cloudify
exit_on_error

vagrant destroy -f centos_final_aws
