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
         	vagrant destroy -f centos6_5_final_cli_aws
		vagrant destroy -f centos7_0_final_cli_aws
		vagrant destroy -f windows_aws
		exit 1
      fi

}

sudo chown tgrid -R /cloudify

#destroy centos machines
vagrant destroy -f centos6_5_final_cli_aws
vagrant destroy -f centos7_0_final_cli_aws
vagrant destroy -f windows_aws

#centos6_5_final_cli_aws
(vagrant up centos6_5_final_cli_aws --provider=aws && 
 centos65_ip=`vagrant ssh-config centos6_5_final_cli_aws | grep HostName | sed "s/HostName//g" | sed "s/ //g"` && 
   echo "centos65_ip=$centos65_ip" && 
   scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
   -i ~/.ssh/aws/vagrant_build.pem \
   root@$centos65_ip:/cloudify/*.rpm /cloudify/cloudify-linux_cli_centos6_5.rpm && exit_on_error) &
sleep 5
#centos7_0_final_cli_aws
(vagrant up centos7_0_final_cli_aws --provider=aws && 
 centos7_ip=`vagrant ssh-config centos7_0_final_cli_aws | grep HostName | sed "s/HostName//g" | sed "s/ //g"` && 
   echo "centos7_ip=$centos7_ip" && 
   scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
   -i ~/.ssh/aws/vagrant_build.pem \
   ec2-user@$centos7_ip:/cloudify/*.rpm /cloudify/cloudify-linux_cli_centos7.rpm && exit_on_error) &
 sleep 5  
  #windows_aws
(vagrant up windows_aws --provider=aws && 
 win_ip=`vagrant ssh-config windows_aws | grep HostName | sed "s/HostName//g" | sed "s/ //g"` && 
   echo "win_ip=win_ip" && 
   scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
   -i ~/.ssh/aws/vagrant_build.pem \
   Administrator@$win_ip:/home/Administrator/packaging/output/*.exe /cloudify/ && exit_on_error) &

wait

#destroy centos machines
vagrant destroy -f centos6_5_final_cli_aws
vagrant destroy -f centos7_0_final_cli_aws
vagrant destroy -f windows_aws
