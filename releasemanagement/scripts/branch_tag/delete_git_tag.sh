#!/bin/sh

source params.sh

PROJECTS_LIST=( Cloudify-iTests-Deployer Cloudify-iTests Cloudify-iTests-webuitf Cloudify-iTests-sandbox  cloudify-recipes cloudify cloudify-widget-recipes iTests-Framework )
#PROJECTS_LIST=( Cloudify-iTests-webuitf Cloudify-iTests-sandbox )


for project in "${PROJECTS_LIST[@]}"
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


	git tag -d  ${TAG_NAME} 
	git push origin  :refs/tags/${TAG_NAME}
	popd
done
