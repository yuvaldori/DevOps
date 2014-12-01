#!/bin/bash

source generic_functions.sh

DSL_SHA=$(echo $DSL_SHA)
REST_CLIENT_SHA=$(echo $REST_CLIENT_SHA)
CLI_SHA=$(echo $CLI_SHA)
OS_PROVIDER_SHA=$(echo $OS_PROVIDER_SHA)
COMMON_PLUGIN_SHA=$(echo $COMMON_PLUGIN_SHA)
PACKMAN_SHA=$(echo $PACKMAN_SHA)
MANAGER_SHA=$(echo $MANAGER_SHA)
SCRIPTS_PLUGIN_SHA=$(echo $SCRIPTS_PLUGIN_SHA)
DIAMOND_PLUGIN_SHA=$(echo $DIAMOND_PLUGIN_SHA)
OS_PLUGIN_SHA=$(echo $OS_PLUGIN_SHA)
FABRIC_PLUGIN_SHA=$(echo $FABRIC_PLUGIN_SHA)


echo "DSL_SHA=$DSL_SHA"
echo "REST_CLIENT_SHA=$REST_CLIENT_SHA"
echo "CLI_SHA=$CLI_SHA"
echo "OS_PROVIDER_SHA=$OS_PROVIDER_SHA"
echo "COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA"
echo "PACKMAN_SHA=$PACKMAN_SHA"
echo "SCRIPTS_PLUGIN_SHA=$SCRIPTS_PLUGIN_SHA"
echo "DIAMOND_PLUGIN_SHA=$DIAMOND_PLUGIN_SHA"
echo "OS_PLUGIN_SHA=$OS_PLUGIN_SHA"
echo "FABRIC_PLUGIN_SHA=$FABRIC_PLUGIN_SHA"
echo "cloudify_packager_dir=$cloudify_packager_dir"

#edit the revision number in linux/provision.sh
fileName="cloudify-cli-packager/vagrant/linux/provision.sh"
sed -i "s/.*DSL_SHA=.*/DSL_SHA=$DSL_SHA/g" $fileName
#exit_on_error
sed -i "s/.*REST_CLIENT_SHA=.*/REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $fileName
#exit_on_error
sed -i "s/.*CLI_SHA=.*/CLI_SHA=$CLI_SHA/g" $fileName
#exit_on_error
sed -i "s/.*OS_PROVIDER_SHA=.*/OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $fileName
#exit_on_error
sed -i "s/.*COMMON_PLUGIN_SHA=.*/COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA/g" $fileName
sed -i "s/.*OS_PLUGIN_SHA=.*/OS_PLUGIN_SHA=$OS_PLUGIN_SHA/g" $fileName
sed -i "s/.*FABRIC_PLUGIN_SHA=.*/FABRIC_PLUGIN_SHA=$FABRIC_PLUGIN_SHA/g" $fileName
sed -i "s/.*SCRIPTS_PLUGIN_SHA=.*/SCRIPTS_PLUGIN_SHA=$SCRIPTS_PLUGIN_SHA/g" $fileName


win_fileName="cloudify-cli-packager/vagrant/windows/provision.bat"
sed -i "s/.*SET DSL_SHA=.*/SET DSL_SHA=$DSL_SHA/g" $win_fileName
#exit_on_error
sed -i "s/.*SET REST_CLIENT_SHA=.*/SET REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $win_fileName
#exit_on_error
sed -i "s/.*SET CLI_SHA=.*/SET CLI_SHA=$CLI_SHA/g" $win_fileName
#exit_on_error
sed -i "s/.*SET OS_PROVIDER_SHA=.*/SET OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $win_fileName
#exit_on_error
sed -i "s/.*SET COMMON_PLUGIN_SHA=.*/SET COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA/g" $win_fileName
sed -i "s/.*SET OS_PLUGIN_SHA=.*/SET OS_PLUGIN_SHA=$OS_PLUGIN_SHA/g" $win_fileName
sed -i "s/.*SET FABRIC_PLUGIN_SHA=.*/SET FABRIC_PLUGIN_SHA=$FABRIC_PLUGIN_SHA/g" $win_fileName
sed -i "s/.*SET SCRIPTS_PLUGIN_SHA=.*/SET SCRIPTS_PLUGIN_SHA=$SCRIPTS_PLUGIN_SHA/g" $win_fileName

win_agent_fileName="$cloudify_packager_dir/vagrant/windows-agent/provision.bat"
sed -i "s/.*SET REST_CLIENT_SHA=.*/SET REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $win_agent_fileName
#exit_on_error
sed -i "s/.*SET COMMON_PLUGIN_SHA=.*/SET COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA/g" $win_agent_fileName
#exit_on_error
sed -i "s/.*SET MANAGER_SHA=.*/SET MANAGER_SHA=$MANAGER_SHA/g" $win_agent_fileName
#exit_on_error
sed -i "s/.*SET SCRIPTS_PLUGIN_SHA=.*/SET SCRIPTS_PLUGIN_SHA=$SCRIPTS_PLUGIN_SHA/g" $win_agent_fileName
sed -i "s/.*SET DIAMOND_PLUGIN_SHA=.*/SET DIAMOND_PLUGIN_SHA=$DIAMOND_PLUGIN_SHA/g" $win_agent_fileName

centos_agent_fileName="$cloudify_packager_dir/vagrant/centos-agent/provision.sh"
ubuntu_agent_p_fileName="$cloudify_packager_dir/vagrant/ubuntu-precise-agent/provision.sh"
ubuntu_agent_t_fileName="$cloudify_packager_dir/vagrant/ubuntu-trusty-agent/provision.sh"
sed -i "s/.*REST_CLIENT_SHA=.*/REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName
#exit_on_error
sed -i "s/.*COMMON_PLUGIN_SHA=.*/COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName
#exit_on_error
sed -i "s/.*MANAGER_SHA=.*/MANAGER_SHA=$MANAGER_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName
#exit_on_error
sed -i "s/.*PACKMAN_SHA=.*/PACKMAN_SHA=$PACKMAN_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName
#exit_on_error
sed -i "s/.*SCRIPTS_PLUGIN_SHA=.*/SCRIPTS_PLUGIN_SHA=$SCRIPTS_PLUGIN_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName
sed -i "s/.*DIAMOND_PLUGIN_SHA=.*/DIAMOND_PLUGIN_SHA=$DIAMOND_PLUGIN_SHA/g" $centos_agent_fileName $ubuntu_agent_p_fileName $ubuntu_agent_t_fileName

components_fileName="$cloudify_packager_dir/vagrant/cloudify-components/provision.sh"
sed -i "s/.*PACKMAN_SHA=.*/PACKMAN_SHA=$PACKMAN_SHA/g" $components_fileName
#exit_on_error
