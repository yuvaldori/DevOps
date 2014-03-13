#!/bin/bash

source params.sh

SVN_HOST=pc-lab14
SVN_URL=svn://${SVN_HOST}/SVN
XAP_SVN_URL=svn://${SVN_HOST}/SVN/xap
XAP_TAGS_SVN_URL=${XAP_SVN_URL}/tags
XAP_BRANCHES_SVN_URL=${XAP_SVN_URL}/branches

TAGS_BRANCHES_FOLDER=${XAP_MAJOR_VERSION}_${XAP_MINOR_VERSION}_X

svn cp ${XAP_TAGS_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${TAG_NAME} ${XAP_BRANCHES_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${BRANCH_NAME} -m "Create branch ${BRANCH_NAME} from ${XAP_TAGS_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${TAG_NAME}"

TEST_PROJECTS_LIST=( Cloudify-iTests Cloudify-iTests-webuitf iTests-Framework )
GIT_PROJECTS_LIST=( mongo-datasource petclinic-jpa )

for project in "${TEST_PROJECTS_LIST[@]}"
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

        git checkout -b ${BRANCH_NAME}  ${TAG_NAME}
        git checkout ${BRANCH_NAME}

        echo "working branch is `git branch`"

        #git commit -m "Change modules maven version to ${CLOUDIFY_MAVEN_VERSION}"
        git push origin  +${BRANCH_NAME}

        popd
done


if [ "${XAP_MAJOR_VERSION}${XAP_MINOR_VERSION}" -gt 96 ]
then 
	echo "*** patch for 9.7 and above ***"
	#for 9.7.0 branches only
	
	for project in "${GIT_PROJECTS_LIST[@]}"
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
	
	
	       git checkout -b ${BRANCH_NAME} ${TAG_NAME}
	       git checkout ${BRANCH_NAME}
	
	       echo "working branch is `git branch`"
	        
	       git push origin  +${BRANCH_NAME}
	
	       popd
	done
	for project in "${GIT_PROJECTS_LIST[@]}"
	do
		pushd ${project}		
		exists=`git show-ref refs/heads/${BRANCH_NAME}`
		if [ -n "$exists" ]; then
	    		echo "*** ${project} - branch: ${BRANCH_NAME} exists"
		else
			echo "*** !!!${project} - branch: ${BRANCH_NAME} does not exist!!!"

		fi	
		popd
	done
fi

for project in "${TEST_PROJECTS_LIST[@]}"
do
	pushd ${project}		
	exists=`git show-ref refs/heads/${BRANCH_NAME}`
	if [ -n "$exists" ]; then
	    	echo "*** ${project} - branch: ${BRANCH_NAME} exists"
	else
		echo "*** !!!${project} - branch: ${BRANCH_NAME} does not exist!!!"

	fi
	popd
done
