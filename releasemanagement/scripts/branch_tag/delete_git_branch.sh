#!/bin/sh

source params.sh

PROJECTS_LIST=( cloudify-recipes cloudify Cloudify-iTests-Deployer Cloudify-iTests Cloudify-iTests-webuitf Cloudify-iTests-sandbox cloudify-widget-recipes iTests-Framework )
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


	git branch -D  ${BRANCH_NAME} 
	git push origin  --delete ${BRANCH_NAME}
	popd
done
