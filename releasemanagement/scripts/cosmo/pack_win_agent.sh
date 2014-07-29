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
		vagrant destroy -f
		exit 1
      fi

}


rm -f /cloudify/Cloudify.exe


##destroy windows vm if exit
vagrant destroy -f


vagrant up --provider=aws
exit_on_error

##get guest ip address
ip_address=`vagrant ssh-config windows | grep HostName | sed "s/HostName//g" | sed "s/ //g"`
echo "ip_address="$ip_address

##copy windows exe file
sudo chown tgrid -R /cloudify
sudo rm -rf /agents/windows-agent
sudo mkdir -p /agents/windows-agent
sudo chown tgrid -R /agents/windows-agent
#sshpass -p 'abcd1234!!' scp -p vagrant@$ip_address:/home/vagrant/cloudify-cli-packager/packaging/windows/inno/Output/CloudifyCLI-3.0.exe /cloudify
scp -p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/aws/windows_agent_packager.pem Administrator@$ip_address:/cygdrive/c/Cloudify.exe /agents/windows-agent
exit_on_error

vagrant destroy -f
