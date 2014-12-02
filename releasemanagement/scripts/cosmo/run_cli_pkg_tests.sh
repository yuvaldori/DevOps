#!/bin/bash

source ../../credentials.sh
source ../../generic_functions.sh

function exit_on_error {
	status=$?
	echo "exit code="$status
	if [ $status != 0 ] ; then
	echo "Failed (exit code $status)"
	vagrant destroy -f
	exit 1
	fi
}

function copy_reports_files {
	##get guest ip address
	ip_address=`vagrant ssh-config linux32 | grep HostName | sed "s/HostName//g" | sed "s/ //g"`
	echo "linux32 ip_address="$ip_address
	echo "creating dir junit_report in "$PWD 
	mkdir junit_reports
	echo "copying report to "$PWD"/junit_reports/nosetests_linux32.xml"
	scp -p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/aws/vagrant_build.pem ubuntu@$ip_address:/home/ubuntu/nosetests.xml junit_reports/nosetests_linux32.xml
	exit_on_error
	ip_address=`vagrant ssh-config linux64 | grep HostName | sed "s/HostName//g" | sed "s/ //g"`
	echo "linux64 ip_address="$ip_address
	scp -p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ~/.ssh/aws/vagrant_build.pem ubuntu@$ip_address:/home/ubuntu/nosetests.xml junit_reports/nosetests_linux64.xml
	exit_on_error
	ip_address=`vagrant ssh-config windows | grep HostName | sed "s/HostName//g" | sed "s/ //g"`
	echo "windows ip_address="$ip_address
	sshpass -p 'abcd1234!!' scp -p -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null Administrator@$ip_address:/home/Administrator/nosetests.xml junit_reports/nosetests_windows.xml
	exit_on_error
	
}
	

function exit_on_error_copy_destroy {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
         	
         	copy_reports_files
		vagrant destroy -f
		exit_on_error
		
		exit 1
      fi

}

#copy cli packages to files/deb32|deb64|exe folders
pushd files/exe
	wget $WIN_CLI_PKG
popd
pushd files/deb64
	wget $LINUX64_CLI_PKG
popd
pushd files/deb32
	wget $LINUX32_CLI_PKG
popd


#edit packages info in settings.ini
ini_fileName="scripts/settings.ini"
sed -i "s|.*path = ../files/exe/.*|path = ../files/exe/`basename $WIN_CLI_PKG`|g" $ini_fileName
sed -i "s|.*path = ../files/deb64/.*|path = ../files/deb64/`basename $LINUX64_CLI_PKG`|g" $ini_fileName
sed -i "s|.*path = ../files/deb32/.*|path = ../files/deb32/`basename $LINUX32_CLI_PKG`|g" $ini_fileName


#edit account info in cloudify-config.yaml
fileName="files/openstack/inputs.json.template"
sed -i "s|\"keystone_username\":.*|\"keystone_username\": \"$(echo ${HP_USER})\",|g" $fileName
sed -i "s|\"keystone_password\":.*|\"keystone_password\": \"$(echo ${HP_PWD})\",|g" $fileName
sed -i "s|\"keystone_tenant_name\":.*|\"keystone_tenant_name\": \"$(echo ${HP_TENANT})\",|g" $fileName
sed -i "s|\"keystone_url\":.*|\"keystone_url\": \"$(echo ${HP_AUTH_URL})\",|g" $fileName


#destroy vms if exit
vagrant destroy -f


vagrant up --provider=aws
exit_on_error_copy_destroy

copy_reports_files

vagrant destroy -f
exit_on_error
#SystemError:
