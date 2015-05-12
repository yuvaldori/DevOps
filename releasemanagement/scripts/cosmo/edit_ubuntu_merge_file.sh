#!/bin/bash -x

docker_ubuntu_merge_file="cloudify-packager/docker/ubuntu_agent/scripts/install_packman.sh"

url_prefix="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE"
if [ "$TRUSTY_TYPE" == "commercial" ]
then
  ubuntu_agent_trusty_commercial_url=$url_prefix"/cloudify-ubuntu-trusty-commercial-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
  ubuntu_agent_precise_commercial_url=$url_prefix"/cloudify-ubuntu-precise-commercial-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
  sed -i "s|.*cloudify-ubuntu-trusty.*|curl $(echo ${ubuntu_agent_trusty_commercial_url}) --create-dirs -o /opt/tmp/manager/ubuntu_trusty_agent.deb \&\& \\\|" $docker_ubuntu_merge_file
  sed -i "s|.*cloudify-ubuntu-precise.*|curl $(echo ${ubuntu_agent_precise_commercial_url}) --create-dirs -o /opt/tmp/manager/ubuntu_precise_agent.deb \&\& \\\|" $docker_ubuntu_merge_file
  sed -i "s|.*pkm pack -c.*|pkm pack -c cloudify-ubuntu-commercial-agent|" $docker_ubuntu_merge_file
else
  ubuntu_agent_trusty_url=$url_prefix"/cloudify-ubuntu-trusty-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
  ubuntu_agent_precise_url=$url_prefix"/cloudify-ubuntu-precise-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
  sed -i "s|.*cloudify-ubuntu-trusty.*|curl $(echo ${ubuntu_agent_trusty_url}) --create-dirs -o /opt/tmp/manager/ubuntu_trusty_agent.deb \&\& \\\|" $docker_ubuntu_merge_file
  sed -i "s|.*cloudify-ubuntu-precise.*|curl $(echo ${ubuntu_agent_precise_url}) --create-dirs -o /opt/tmp/manager/ubuntu_precise_agent.deb \&\& \\\|" $docker_ubuntu_merge_file
  sed -i "s|.*pkm pack -c.*|pkm pack -c cloudify-ubuntu-agent|" $docker_ubuntu_merge_file
fi
