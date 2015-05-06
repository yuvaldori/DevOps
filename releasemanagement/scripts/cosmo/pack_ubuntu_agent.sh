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
		vagrant destroy -f ubuntu_trusty_aws
		vagrant destroy -f ubuntu_trusty_commercial_aws
		exit 1
      fi

}

sudo chown tgrid -R /cloudify

#destroy machines
vagrant destroy -f ubuntu_trusty_aws
vagrant destroy -f ubuntu_trusty_commercial_aws

#ubuntu_trusty_aws
(vagrant up ubuntu_trusty_aws --provider=aws && 
 trusty_ip=`vagrant ssh-config ubuntu_trusty_aws | grep HostName | sed "s/HostName//g" | sed "s/ //g"` && 
   echo "trusty_ip=$trusty_ip" && 
   scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
   -i ~/.ssh/aws/vagrant_build.pem \
   ubuntu@$trusty_ip:/cloudify/*.deb /cloudify/cloudify-ubuntu-trusty-agent.deb && exit_on_error) &

#ubuntu_trusty_commercial_aws
(vagrant up ubuntu_trusty_commercial_aws --provider=aws && 
 trustyc_ip=`vagrant ssh-config ubuntu_trusty_commercial_aws | grep HostName | sed "s/HostName//g" | sed "s/ //g"` && 
   echo "trustyc_ip=$trustyc_ip" && 
   scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
   -i ~/.ssh/aws/vagrant_build.pem \
   ubuntu@$trustyc_ip:/cloudify/*.deb /cloudify/cloudify-ubuntu-trusty-commercial-agent.deb && exit_on_error) &

wait

#destroy machines
vagrant destroy -f ubuntu_trusty_aws
vagrant destroy -f ubuntu_trusty_commercial_aws
