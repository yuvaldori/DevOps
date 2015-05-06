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
		vagrant destroy -f ubuntu_precise_aws
		vagrant destroy -f ubuntu_precise_commercial_aws
		exit 1
      fi

}

sudo chown tgrid -R /cloudify

#destroy machines
vagrant destroy -f ubuntu_precise_aws
vagrant destroy -f ubuntu_precise_commercial_aws

#ubuntu_precise_aws
(vagrant up ubuntu_precise_aws --provider=aws && 
 precise_ip=`vagrant ssh-config ubuntu_precise_aws | grep HostName | sed "s/HostName//g" | sed "s/ //g"` && 
   echo "precise_ip=$precise_ip" && 
   scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
   -i ~/.ssh/aws/vagrant_build.pem \
   ubuntu@$precise_ip:/cloudify/*.deb /cloudify/cloudify-ubuntu-precise-agent.deb && exit_on_error) &

#ubuntu_precise_commercial_aws
(vagrant up ubuntu_precise_commercial_aws --provider=aws && 
 precisec_ip=`vagrant ssh-config ubuntu_precise_commercial_aws | grep HostName | sed "s/HostName//g" | sed "s/ //g"` && 
   echo "precisec_ip=$precisec_ip" && 
   scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
   -i ~/.ssh/aws/vagrant_build.pem \
   ubuntu@$precisec_ip:/cloudify/*.deb /cloudify/cloudify-ubuntu-precise-commercial-agent.deb && exit_on_error) &

wait

#destroy machines
vagrant destroy -f ubuntu_precise_aws
vagrant destroy -f ubuntu_precise_commercial_aws
