#!/bin/sh

BRANCH_NAME=ipv6
CLOUDIFY_MAVEN_VERSION=2.6.0-SNAPSHOT
XAP_MAVEN_VERSION=9.6.0-SNAPSHOT

TEST_PROJECTS_LIST=( Cloudify-iTests-Deployer Cloudify-iTests-webuitf Cloudify-iTests-sandbox )
CLOUDIFY_PROJECTS_LIST=( cloudify-recipes cloudify-widget-recipes )

for project in "${CLOUDIFY_PROJECTS_LIST[@]}"
do	
	if [ -d ${project}/.git ]; then
		pushd ${project}
		git pull
	else
		
		git clone "https://opencm:g!ga0pencm@github.com/CloudifySource/${project}.git"
		pushd ${project}
	fi

	project_parent_pom_folder=`pwd` 
	
	project_home=`pwd`	

	git checkout master

	git checkout -b ${BRANCH_NAME}  
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
                git pull
        else
                git clone "https://opencm:g!ga0pencm@github.com/CloudifySource/${project}.git"
                pushd ${project}
        fi

        git checkout master

        git checkout -b ${BRANCH_NAME}
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

