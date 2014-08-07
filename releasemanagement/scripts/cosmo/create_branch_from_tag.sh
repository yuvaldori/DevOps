#!/bin/bash -x

source generic_functions.sh
GIT_PWD=$(cat params.sh | grep GIT_PWD= | awk -F'=' '{print $2}')

echo "GIT_PWD=$GIT_PWD"
#echo "PACK_CORE=$PACK_CORE"
#echo "PACK_CLI=$PACK_CLI"
#echo "PACK_UI=$PACK_UI"
#echo "CORE_REPOS_LIST=$CORE_REPOS_LIST"
#echo "CLI_REPOS_LIST=$CLI_REPOS_LIST"
#echo "UI_REPOS_LIST=$UI_REPOS_LIST"
#echo "PACKAGER_REPOS_LIST=$PACKAGER_REPOS_LIST"
echo "TAG_NAME_TO_PREPARE_BRANCH_FROM=$TAG_NAME_TO_PREPARE_BRANCH_FROM"
echo "BRANCH_NAME_FROM_TAG=$BRANCH_NAME_FROM_TAG"

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
if [ "$PACK_UI" == "yes" ] || [ "$PACK_CORE" == "yes" ]
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
		if [ "${project}" == "cosmo-ui" ]; then 
		  git clone $(echo "https://opencm:${GIT_PWD}@github.com/CloudifySource/${project}.git" | tr -d '\r')
		  exit_on_error
		else
		  git clone $(echo "https://opencm:${GIT_PWD}@github.com/cloudify-cosmo/${project}.git" | tr -d '\r')
		  exit_on_error
		fi
		pushd ${project}
		git checkout master
		exit_on_error
	fi

	git checkout -b ${BRANCH_NAME_FROM_TAG} ${TAG_NAME_TO_PREPARE_BRANCH_FROM} 
	exit_on_error
	git checkout ${BRANCH_NAME_FROM_TAG}  
	exit_on_error

	echo "working branch is `git branch`"
	#git push origin ${BRANCH_NAME_FROM_TAG}
	#exit_on_error
	
	popd
done
