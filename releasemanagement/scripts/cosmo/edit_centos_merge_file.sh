#!/bin/bash -x

docker_centos_merge_file="cloudify-packager/docker/centos_agent/scripts/install_packman.sh"

url_prefix="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE"
centos_agent_final_url=$url_prefix"/cloudify-centos-final-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
centos_agent_core_url=$url_prefix"/cloudify-centos-core-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
sed -i "s|.*cloudify-centos-final.*|curl $(echo ${centos_agent_final_url}) --create-dirs -o /opt/tmp/manager/centos_final_agent.deb \&\& \\\|" $docker_centos_merge_file
sed -i "s|.*cloudify-centos-core.*|curl $(echo ${centos_agent_core_url}) --create-dirs -o /opt/tmp/manager/centos_core_agent.deb \&\& \\\|" $docker_centos_merge_file
sed -i "s|.*pkm pack -c.*|pkm pack -c cloudify-centos-agent|" $docker_centos_merge_file