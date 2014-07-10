#!/bin/bash

#DSL_SHA=d2bedb39b62bddc3888c09e21163ab987f3d4883
#REST_CLIENT_SHA=b84591d8fb024f9bbf4679f361d15ec18fc1cae1
#CLI_SHA=1fee425e6a2f21a231f023fae4d7885ad07a0e4e
#OS_PROVIDER_SHA=2fa30b0b6b9c2e20068ed3d68e160390f309fcee
#PLUGIN_COMMON_SHA=2fa30b0b6b9c2e20068ed3d68e160390f30999999


DSL_SHA=$(echo $DSL_SHA)
REST_CLIENT_SHA=$(echo $REST_CLIENT_SHA)
CLI_SHA=$(echo $CLI_SHA)
OS_PROVIDER_SHA=$(echo $OS_PROVIDER_SHA)
PLUGIN_COMMON_SHA=$(echo $PLUGIN_COMMON_SHA)

echo "DSL_SHA=$DSL_SHA"
echo "REST_CLIENT_SHA=$REST_CLIENT_SHA"
echo "CLI_SHA=$CLI_SHA"
echo "OS_PROVIDER_SHA=$OS_PROVIDER_SHA"
echo "PLUGIN_COMMON_SHA=$PLUGIN_COMMON_SHA"


#edit the revision number in linux/provision.sh
fileName="cloudify-cli-packager/vagrant/linux/provision.sh"
sed -i "s/.*DSL_SHA=.*/DSL_SHA=$DSL_SHA/g" $fileName
sed -i "s/.*REST_CLIENT_SHA=.*/REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $fileName
sed -i "s/.*CLI_SHA=.*/CLI_SHA=$CLI_SHA/g" $fileName
sed -i "s/.*OS_PROVIDER_SHA=.*/OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $fileName

win_fileName="cloudify-cli-packager/vagrant/windows/provision.bat"
sed -i "s/.*SET DSL_SHA=.*/SET DSL_SHA=$DSL_SHA/g" $win_fileName
sed -i "s/.*SET REST_CLIENT_SHA=.*/SET REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $win_fileName
sed -i "s/.*SET CLI_SHA=.*/SET CLI_SHA=$CLI_SHA/g" $win_fileName
sed -i "s/.*SET OS_PROVIDER_SHA=.*/SET OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $win_fileName

win_agent_fileName="cloudify-packager-ubuntu/vagrant/windows-agent/provision.bat"
sed -i "s/.*SET REST_CLIENT_SHA=.*/SET REST_CLIENT_SHA=$REST_CLIENT_SHA/g" $win_agent_fileName
sed -i "s/.*SET PLUGIN_COMMON_SHA=.*/SET PLUGIN_COMMON_SHA=$PLUGIN_COMMON_SHA/g" $win_agent_fileName
sed -i "s/.*SET OS_PROVIDER_SHA=.*/SET OS_PROVIDER_SHA=$OS_PROVIDER_SHA/g" $win_agent_fileName


defaults_config_yaml_file="cloudify-openstack-provider/cloudify_openstack/cloudify-config.defaults.yaml"
config_yaml_file="cloudify-openstack-provider/cloudify_openstack/cloudify-config.yaml"

components_package_url=$(grep "cloudify_components_package_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_components_package_url: //')
core_package_url=$(grep "cloudify_core_package_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_core_package_url: //')
ui_package_url=$(grep "cloudify_ui_package_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_ui_package_url: //')
ubuntu_agent_url=$(grep "cloudify_ubuntu_agent_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_ubuntu_agent_url: //')
windows_agent_url=$(grep "cloudify_windows_agent_url:" cloudify-packager-ubuntu/nightly-aws.links | sed 's/cloudify_windows_agent_url: //')

sed -i "s|{{ components_package_url }}|$(echo ${components_package_url})|g" $defaults_config_yaml_file $config_yaml_file
sed -i "s|{{ core_package_url }}|$(echo ${core_package_url})|g" $defaults_config_yaml_file $config_yaml_file
sed -i "s|{{ ui_package_url }}|$(echo ${ui_package_url})|g" $defaults_config_yaml_file $config_yaml_file
sed -i "s|{{ ubuntu_agent_url }}|$(echo ${ubuntu_agent_url})|g" $defaults_config_yaml_file $config_yaml_file
sed -i "s|{{ windows_agent_url }}|$(echo ${windows_agent_url})|g" $defaults_config_yaml_file $config_yaml_file

git commit -m 'replace urls in config yaml files' $defaults_config_yaml_file $config_yaml_file
