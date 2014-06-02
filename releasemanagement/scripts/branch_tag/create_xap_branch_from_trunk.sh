#!/bin/bash

source params.sh


BRANCH_NAME=${XAP_MAJOR_VERSION}_${XAP_MINOR_VERSION}_${XAP_SERVICE_PACK}_${MILESTONE}

svn cp ${XAP_TRUNK_SVN_URL} ${XAP_BRANCHES_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${BRANCH_NAME} -m "Create branch ${BRANCH_NAME} from ${XAP_TRUNK_SVN_URL}, revision: ${SVN_REVISION_NUMBER}"

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


        git checkout -b ${BRANCH_NAME}
        git checkout ${BRANCH_NAME}

        echo "working branch is `git branch`"

        #git commit -m "Change modules maven version to ${CLOUDIFY_MAVEN_VERSION}"
        git push origin  +${BRANCH_NAME}

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


       git checkout -b ${BRANCH_NAME}
       git checkout ${BRANCH_NAME}

       echo "working branch is `git branch`"
        
       git push origin  +${BRANCH_NAME}

   popd
done

for project in ${TEST_PROJECTS_LIST[@]}
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
for project in ${GIT_PROJECTS_LIST[@]}
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
