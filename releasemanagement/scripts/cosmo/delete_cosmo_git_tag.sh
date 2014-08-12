#!/bin/bash

PROJECTS_LIST_CORE=( cloudify-manager cloudify-plugins-common cloudify-plugin-template cloudify-dsl-parser cloudify-rest-client cloudify-system-tests cloudify-cli cloudify-examples cloudify-nodecellar-openstack )
PROJECTS_LIST_PLUGIN=( cloudify-chef-plugin cloudify-bash-plugin cloudify-python-plugin cloudify-openstack-provider cloudify-openstack-plugin cloudify-puppet-plugin cloudify-packager-centos packman cloudify-packager-ubuntu )
CORE_TAG_NAME="nightly"
PLUGINS_TAG_NAME="nightly"

for project in "${PROJECTS_LIST_CORE[@]}"
do
	if [ -d ${project}/.git ]; then
		pushd ${project}
		git checkout master
		git pull
	else
		git clone "https://opencm:${GIT_PWD}@github.com/CloudifySource/${project}.git"
		pushd ${project}
		git checkout master
	fi

	git tag -d  $CORE_TAG_NAME 
	git push origin  :refs/tags/$CORE_TAG_NAME
	popd
done

for project in "${PROJECTS_LIST_PLUGIN[@]}"
do
	if [ -d ${project}/.git ]; then
		pushd ${project}
		git checkout master
		git pull
	else
		git clone "https://opencm:${GIT_PWD}@github.com/CloudifySource/${project}.git"
		pushd ${project}
		git checkout master
	fi

	git tag -d  $PLUGINS_TAG_NAME 
	git push origin  :refs/tags/$PLUGINS_TAG_NAME
	popd
done

