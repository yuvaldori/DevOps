#!/bin/bash -x

docker_ubuntu_merge_file="cloudify-packager/docker/ubuntu_agent/scripts/install_packman.sh"

url_prefix="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE"
ubuntu_agent_trusty_url=$url_prefix"/cloudify-ubuntu-trusty-commercial-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
sed -i "s|.*cloudify-ubuntu-trusty-agent.*|curl $(echo ${ubuntu_agent_trusty_url}) --create-dirs -o /opt/tmp/manager/ubuntu_trusty_agent.deb \&\& \\\|" $docker_ubuntu_merge_file
