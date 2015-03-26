#!/bin/bash

source generic_functions.sh

#DSL_SHA=$(echo $DSL_SHA)


win_agent_fileName="$cloudify_packager_dir/vagrant/windows-agent/provision.bat"
sed -i "s/.*SET REST_CLIENT_SHA=.*/SET REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $win_agent_fileName
sed -i "s/.*SET COMMON_PLUGIN_SHA=.*/SET COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA/g" $win_agent_fileName
sed -i "s/.*SET MANAGER_SHA=.*/SET MANAGER_SHA=$MANAGER_SHA/g" $win_agent_fileName
sed -i "s/.*SET SCRIPTS_PLUGIN_SHA=.*/SET SCRIPTS_PLUGIN_SHA=$SCRIPTS_PLUGIN_SHA/g" $win_agent_fileName
sed -i "s/.*SET DIAMOND_PLUGIN_SHA=.*/SET DIAMOND_PLUGIN_SHA=$DIAMOND_PLUGIN_SHA/g" $win_agent_fileName
ubuntu_agent_p_fileName="$cloudify_packager_dir/vagrant/ubuntu-precise-agent/provision.sh"
ubuntu_agent_t_fileName="$cloudify_packager_dir/vagrant/ubuntu-trusty-agent/provision.sh"
sed -i "s/.*REST_CLIENT_SHA=.*/REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName $fileName $vbox_fileName
sed -i "s/.*COMMON_PLUGIN_SHA=.*/COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName $fileName $vbox_fileName
sed -i "s/.*MANAGER_SHA=.*/MANAGER_SHA=$MANAGER_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName
sed -i "s/.*PACKMAN_SHA=.*/PACKMAN_SHA=$PACKMAN_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName $components_fileName
sed -i "s/.*SCRIPTS_PLUGIN_SHA=.*/SCRIPTS_PLUGIN_SHA=$SCRIPTS_PLUGIN_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName $fileName $vbox_fileName
sed -i "s/.*DIAMOND_PLUGIN_SHA=.*/DIAMOND_PLUGIN_SHA=$DIAMOND_PLUGIN_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName
sed -i "s/.*DSL_SHA=.*/DSL_SHA=$DSL_SHA/g" $fileName $vbox_fileName
sed -i "s/.*CLI_SHA=.*/CLI_SHA=$CLI_SHA/g" $fileName $vbox_fileName
sed -i "s/.*OS_PROVIDER_SHA=.*/OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $fileName
sed -i "s/.*OS_PLUGIN_SHA=.*/OS_PLUGIN_SHA=$OS_PLUGIN_SHA/g" $fileName
sed -i "s/.*FABRIC_PLUGIN_SHA=.*/FABRIC_PLUGIN_SHA=$FABRIC_PLUGIN_SHA/g" $fileName
sed -i "s/.*MANAGER_BLUEPRINTS_SHA=.*/MANAGER_BLUEPRINTS_SHA=$MANAGER_BLUEPRINTS_SHA/g" $vbox_fileName
sed -i "s/.*PACKAGER_SHA=.*/PACKAGER_SHA=$PACKAGER_SHA/g" $docker_file

cli_win_fileName="cloudify-cli-packager/vagrant/windows/provision.bat"
sed -i "s/.*SET CORE_TAG_NAME=.*/SET CORE_TAG_NAME=$CORE_TAG_NAME/g" $cli_win_fileName
sed -i "s/.*SET PLUGINS_TAG_NAME=.*/SET PLUGINS_TAG_NAME=$PLUGINS_TAG_NAME/g" $cli_win_fileName
vbox_file="$cloudify_packager_dir/image-builder/provision/common.sh"
docker_file="$cloudify_packager_dir/vagrant/docker_images/provision.sh"
debian_agent_file="cloudify-packager/vagrant/debian-jessie-agent/provision.sh"
sed -i "s/.*CORE_TAG_NAME=.*/CORE_TAG_NAME=$core_tag_name/g" $debian_agent_file $vbox_file $docker_file
sed -i "s/.*PLUGINS_TAG_NAME=.*/PLUGINS_TAG_NAME=$plugins_tag_name/g" $debian_agent_file $vbox_file $docker_file

