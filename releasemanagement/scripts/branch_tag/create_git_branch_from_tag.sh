#!/bin/sh

source params.sh

SVN_HOST=pc-lab14
SVN_URL=svn://${SVN_HOST}/SVN
CLOUDIFY_SVN_URL=svn://${SVN_HOST}/SVN/cloudify
CLOUDIFY_TRUNK_SVN_URL=${CLOUDIFY_SVN_URL}/trunk
CLOUDIFY_TAGS_SVN_URL=${CLOUDIFY_SVN_URL}/tags
CLOUDIFY_BRANCHES_SVN_URL=${CLOUDIFY_SVN_URL}/branches

BRANCH_NAME=${CLOUDIFY_MAJOR_VERSION}_${CLOUDIFY_MINOR_VERSION}_${CLOUDIFY_SERVICEPACK_VERSION}_m8_Huawei_demo 
TAGS_BRANCHES_FOLDER=${CLOUDIFY_MAJOR_VERSION}_${CLOUDIFY_MINOR_VERSION}_X
CLOUDIFY_MAVEN_VERSION=${CLOUDIFY_MAJOR_VERSION}.${CLOUDIFY_MINOR_VERSION}.${CLOUDIFY_SERVICEPACK_VERSION}-SNAPSHOT
XAP_MAVEN_VERSION=9.7.0-SNAPSHOT
TAG_NAME_TO_PREPARE_BRANCH_FROM=2.7.0_m8_build5993_12_11_2013

TEST_PROJECTS_LIST=( Cloudify-iTests-Deployer Cloudify-iTests Cloudify-iTests-webuitf Cloudify-iTests-sandbox iTests-Framework )
#CLOUDIFY_PROJECTS_LIST=( cloudify-recipes cloudify cloudify-widget-recipes )
CLOUDIFY_PROJECTS_LIST=( cloudify-recipes cloudify )


svn cp ${CLOUDIFY_TAGS_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${TAG_NAME_TO_PREPARE_BRANCH_FROM} ${CLOUDIFY_BRANCHES_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${BRANCH_NAME} -m "Create branch ${BRANCH_NAME} from ${TAG_NAME_TO_PREPARE_BRANCH_FROM}"


for project in "${CLOUDIFY_PROJECTS_LIST[@]}"
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

	project_parent_pom_folder=`pwd` 
	
	project_home=`pwd`	


	git checkout -b ${BRANCH_NAME} ${TAG_NAME_TO_PREPARE_BRANCH_FROM} 
	git checkout ${BRANCH_NAME}  

	echo "working branch is `git branch`"
	
	if [ "${project}" == "cloudify" ]; then
		project_parent_pom_folder=`pwd`/cloudify
	fi
	pushd ${project_parent_pom_folder}

	mvn versions:set -DgenerateBackupPoms=false -DnewVersion=${CLOUDIFY_MAVEN_VERSION} 

	sed   s:'\(<gsVersion>\)\(.*\)\(</gsVersion>\)':"\1${XAP_MAVEN_VERSION}\3":g pom.xml > pom.xml.1
        rm pom.xml
        mv pom.xml.1 pom.xml

	git add ${project_home}
	git status
	
	git commit -m "Change modules maven version to ${CLOUDIFY_MAVEN_VERSION}"
	git push origin  +${BRANCH_NAME}
		
	popd
	popd
done

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


        git checkout -b ${BRANCH_NAME}  ${TAG_NAME_TO_PREPARE_BRANCH_FROM}
	git checkout ${BRANCH_NAME} 

	echo "working branch is `git branch`"	

        sed   s:'\(<gsVersion>\)\(.*\)\(</gsVersion>\)':"\1${XAP_MAVEN_VERSION}\3":g pom.xml > pom.xml.1
	rm pom.xml
	mv pom.xml.1 pom.xml

	sed   s:'\(<cloudifyVersion>\)\(.*\)\(</cloudifyVersion>\)':"\1${CLOUDIFY_MAVEN_VERSION}\3":g pom.xml > pom.xml.1
	rm pom.xml
        mv pom.xml.1 pom.xml
        
	git add .
        git status

        git commit -m "Change modules maven version to ${CLOUDIFY_MAVEN_VERSION}"
        git push origin  +${BRANCH_NAME}

        popd
done

