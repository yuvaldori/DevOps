#!/bin/sh

#source params.sh
BRANCH_NAME="9_7_1_m1"

TEST_PROJECTS_LIST=( Cloudify-iTests Cloudify-iTests-webuitf iTests-Framework )
GIT_PROJECTS_LIST=( mongo-datasource petclinic-jpa )


for project in ${TEST_PROJECTS_LIST[@]}
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

for project in ${GIT_PROJECTS_LIST[@]}
do
	if [ -d ${project}/.git ]; then
		pushd ${project}
		git checkout master
		git pull
	else
		git clone "https://opencm:${GIT_PWD}@github.com/Gigaspaces/${project}.git"
		pushd ${project}
		git checkout master
	fi


	git branch -D  ${BRANCH_NAME} 
	git push origin  --delete ${BRANCH_NAME}
	popd
done
