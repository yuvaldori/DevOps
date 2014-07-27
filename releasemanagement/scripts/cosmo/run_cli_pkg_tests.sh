#!/bin/bash

source ../../cli_credentials.sh
source ../../generic_functions.sh

#WIN_CLI_PKG=http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-windows-cli.exe
#LINUX64_CLI_PKG=http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-linux64-cli_amd64.deb
#LINUX32_CLI_PKG=http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/nightly/cloudify-linux32-cli_i386.deb
#HP_USER=hpcloud@gigaspaces.com
#HP_PWD=GS-bu1ld
#HP_TENANT=hpcloud@gigaspaces.com
#HP_AUTH_URL=https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/

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
yaml_fileName="files/openstack/cloudify-config.yaml"
sed -i "s|.*username:.*|    username: $HP_USER|g" $yaml_fileName
sed -i "s|.*password:.*|    password: $HP_PWD|g" $yaml_fileName
sed -i "s|.*tenant_name:.*|    tenant_name: $HP_TENANT|g" $yaml_fileName
sed -i "s|.*auth_url:.*|    auth_url: $HP_AUTH_URL|g" $yaml_fileName

#destroy vms if exit
vagrant destroy -f


vagrant up --provider=aws
exit_on_error

#get guest ip address
#s=`vagrant ssh linux32 -- ec2metadata | grep public-hostname | cut -f1 -d"." | cut -d" " -f2` ; s=${s#ec2-} ; ip_address=${s//-/.}
#echo "ip_address="$ip_address

#copy linux32 deb file
#sudo chown tgrid -R /cloudify
#scp -i ~/.ssh/aws/vagrant_build.pem ubuntu@$ip_address:~/cloudify-cli-packager/pyinstaller/*.deb /cloudify
#exit_on_error

#vagrant destroy -f linux32

#SystemError:
