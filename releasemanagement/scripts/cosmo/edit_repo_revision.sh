#!/bin/bash

source generic_functions.sh

#DSL_SHA=$(echo $DSL_SHA)

win_agent_fileName="$cloudify_packager_dir/vagrant/agents/provision.bat"
cli_win_fileName="cloudify-cli-packager/vagrant/windows/provision.bat"
cli_win_fileName1="cloudify-packager/vagrant/cli/provision.bat"
sed -i "s/.*SET CORE_TAG_NAME=.*/SET CORE_TAG_NAME=$core_tag_name/g" $cli_win_fileName $win_agent_fileName $cli_win_fileName1
sed -i "s/.*SET PLUGINS_TAG_NAME=.*/SET PLUGINS_TAG_NAME=$plugins_tag_name/g" $cli_win_fileName $win_agent_fileName $cli_win_fileName1
linux_agent_file="$cloudify_packager_dir/vagrant/agents/provision.sh"
linux_cli_file="$cloudify_packager_dir/vagrant/cli/provision.sh"
vbox_file="cloudify-packager/image-builder/quickstart-vagrantbox/provision/common.sh"
docker_file="$cloudify_packager_dir/vagrant/docker_images/provision.sh"
ubuntu_merge_file="cloudify-packager/docker/ubuntu_agent/scripts/install_packman.sh"
sed -i "s/.*CORE_TAG_NAME=.*/CORE_TAG_NAME=$core_tag_name/g" $linux_agent_file $vbox_file $docker_file $linux_cli_file $ubuntu_merge_file
sed -i "s/.*PLUGINS_TAG_NAME=.*/PLUGINS_TAG_NAME=$plugins_tag_name/g" $linux_agent_file $vbox_file $docker_file $linux_cli_file
