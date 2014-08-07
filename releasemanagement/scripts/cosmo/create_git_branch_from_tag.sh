#!/bin/bash -x

source generic_functions.sh
GIT_PWD=$(cat params.sh | grep GIT_PWD= | awk -F'=' '{print $2}')

if [ "$PACK_CORE" == "yes" ]
then
	REPOS_LIST=$CORE_REPOS_LIST
fi
if [ "$PACK_CLI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$CLI_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$UI_REPOS_LIST
fi
if [[ "$PACK_UI" == "yes" || "$PACK_CORE" == "yes" ]]
then
	REPOS_LIST=$REPOS_LIST" "$PACKAGER_REPOS_LIST
fi

echo "REPOS_LIST=$REPOS_LIST"

echo "### Repositories list: $REPOS_LIST"

for project in ${REPOS_LIST}
do	
	if [ -d ${project}/.git ]; then
		pushd ${project}
		git checkout master
		git pull
	else
		if [ "${project}" == "cosmo-ui"]; then 
		  git clone "https://opencm:${GIT_PWD}@github.com/cloudify-cosmo/${project}.git"
		else
		  git clone "https://opencm:${GIT_PWD}@github.com/CloudifySource/${project}.git"
		pushd ${project}
		git checkout master
	fi

	git checkout -b ${BRANCH_NAME} ${TAG_NAME_TO_PREPARE_BRANCH_FROM} 
	git checkout ${BRANCH_NAME}  

	echo "working branch is `git branch`"
	git push origin ${BRANCH_NAME}
		
	
	popd
done
