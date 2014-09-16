#!/bin/bash

source generic_functions.sh

#DSL_SHA=$(echo $DSL_SHA)
#REST_CLIENT_SHA=$(echo $REST_CLIENT_SHA)
#CLI_SHA=$(echo $CLI_SHA)
#OS_PROVIDER_SHA=$(echo $OS_PROVIDER_SHA)
#PLUGIN_COMMON_SHA=$(echo $PLUGIN_COMMON_SHA)

echo "DSL_SHA=$DSL_SHA"
echo "REST_CLIENT_SHA=$REST_CLIENT_SHA"
echo "CLI_SHA=$CLI_SHA"
echo "OS_PROVIDER_SHA=$OS_PROVIDER_SHA"
echo "COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA"
echo "PACKMAN_SHA=$PACKMAN_SHA"

#edit the revision number in linux/provision.sh
fileName="cloudify-cli-packager/vagrant/linux/provision.sh"
sed -i "s/.*DSL_SHA=.*/DSL_SHA=$DSL_SHA/g" $fileName
exit_on_error
sed -i "s/.*REST_CLIENT_SHA=.*/REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $fileName
exit_on_error
sed -i "s/.*CLI_SHA=.*/CLI_SHA=$CLI_SHA/g" $fileName
exit_on_error
sed -i "s/.*OS_PROVIDER_SHA=.*/OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $fileName
exit_on_error

win_fileName="cloudify-cli-packager/vagrant/windows/provision.bat"
sed -i "s/.*SET DSL_SHA=.*/SET DSL_SHA=$DSL_SHA/g" $win_fileName
exit_on_error
sed -i "s/.*SET REST_CLIENT_SHA=.*/SET REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $win_fileName
exit_on_error
sed -i "s/.*SET CLI_SHA=.*/SET CLI_SHA=$CLI_SHA/g" $win_fileName
exit_on_error
sed -i "s/.*SET OS_PROVIDER_SHA=.*/SET OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $win_fileName
exit_on_error

win_agent_fileName="cloudify-packager-ubuntu/vagrant/windows-agent/provision.bat"
sed -i "s/.*SET REST_CLIENT_SHA=.*/SET REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $win_agent_fileName
exit_on_error
sed -i "s/.*SET PLUGIN_COMMON_SHA=.*/SET PLUGIN_COMMON_SHA=$PLUGIN_COMMON_SHA/g" $win_agent_fileName
exit_on_error
sed -i "s/.*SET OS_PROVIDER_SHA=.*/SET OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $win_agent_fileName
exit_on_error

centos_agent_fileName="  cloudify-packager-centos/vagrant/centos-agent/provision.sh"
sed -i "s/.*SET REST_CLIENT_SHA=.*/SET REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $centos_agent_fileName
exit_on_error
sed -i "s/.*SET COMMON_PLUGIN_SHA=.*/SET COMMON_PLUGIN_SHA=$COMMON_PLUGIN_SHA/g" $centos_agent_fileName
exit_on_error
sed -i "s/.*SET MANAGER_SHA=.*/SET MANAGER_SHA=$MANAGER_SHA/g" $centos_agent_fileName
exit_on_error
sed -i "s/.*SET PACKMAN_SHA=.*/SET PACKMAN_SHA=$PACKMAN_SHA/g" $centos_agent_fileName
exit_on_error

components_fileName="  cloudify-packager-ubuntu/vagrant/cloudify-components/provision.sh"
sed -i "s/.*SET PACKMAN_SHA=.*/SET PACKMAN_SHA=$PACKMAN_SHA/g" $components_fileName
exit_on_error

