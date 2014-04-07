#!/bin/bash

source params.sh

SVN_HOST=pc-lab14
SVN_URL=svn://${SVN_HOST}/SVN
XAP_SVN_URL=svn://${SVN_HOST}/SVN/xap
XAP_TRUNK_SVN_URL=${XAP_SVN_URL}/trunk
XAP_TAGS_SVN_URL=${XAP_SVN_URL}/tags
XAP_BRANCHES_SVN_URL=${XAP_SVN_URL}/branches

TAGS_BRANCHES_FOLDER=${XAP_MAJOR_VERSION}_${XAP_MINOR_VERSION}_X

BRANCH_NAME=${XAP_MAJOR_VERSION}_${XAP_MINOR_VERSION}_${XAP_SERVICE_PACK}_${MILESTONE}
SVN_REVISION_NUMBER=`svn info ${XAP_TRUNK_SVN_URL} | grep Revision | awk '{print $2}'`
svn cp ${XAP_TRUNK_SVN_URL} ${XAP_BRANCHES_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${BRANCH_NAME} -m "Create branch ${BRANCH_NAME} from ${XAP_TRUNK_SVN_URL}, revision: ${SVN_REVISION_NUMBER}"

TEST_PROJECTS_LIST=( Cloudify-iTests Cloudify-iTests-webuitf iTests-Framework )
GIT_PROJECTS_LIST=( mongo-datasource mongo-datasource-itests petclinic-jpa )
#ENTIRE_PROJECTS_LIST="${GIT_PROJECTS_LIST} ${TEST_PROJECTS_LIST}"

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
