#!/bin/sh

source params.sh

SVN_HOST=pc-lab14
SVN_URL=svn://${SVN_HOST}/SVN
CLOUDIFY_SVN_URL=svn://${SVN_HOST}/SVN/cloudify
CLOUDIFY_TRUNK_SVN_URL=${CLOUDIFY_SVN_URL}/trunk
CLOUDIFY_TAGS_SVN_URL=${CLOUDIFY_SVN_URL}/tags
CLOUDIFY_BRANCHES_SVN_URL=${CLOUDIFY_SVN_URL}/branches

BRANCH_NAME=${CLOUDIFY_MAJOR_VERSION}_${CLOUDIFY_MINOR_VERSION}_${CLOUDIFY_SERVICEPACK_VERSION}_${MILESTONE}
TAGS_BRANCHES_FOLDER=${CLOUDIFY_MAJOR_VERSION}_${CLOUDIFY_MINOR_VERSION}_X
CLOUDIFY_MAVEN_VERSION=${CLOUDIFY_MAJOR_VERSION}.${CLOUDIFY_MINOR_VERSION}.${CLOUDIFY_SERVICEPACK_VERSION}-SNAPSHOT
XAP_MAVEN_VERSION=${XAP_MAJOR_VERSION}.${XAP_MINOR_VERSION}.${XAP_SERVICE_PACK}-SNAPSHOT

svn cp ${CLOUDIFY_BRANCHES_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${BRANCH_NAME_OLD} ${CLOUDIFY_BRANCHES_SVN_URL}/${TAGS_BRANCHES_FOLDER}/${BRANCH_NAME} -m "Create branch ${BRANCH_NAME} from branch ${BRANCH_NAME_OLD}"


TEST_PROJECTS_LIST=( Cloudify-iTests-Deployer Cloudify-iTests Cloudify-iTests-webuitf Cloudify-iTests-sandbox iTests-Framework )
CLOUDIFY_PROJECTS_LIST=( cloudify-recipes cloudify cloudify-widget-recipes )

CONCATE_PROJECTS_LIST="${TEST_PROJECTS_LIST[@]} ${CLOUDIFY_PROJECTS_LIST[@]}"

for project in "${CLOUDIFY_PROJECTS_LIST[@]}"
do	
	if [ -d ${project}/.git ]; then
		pushd ${project}
		git checkout ${BRANCH_NAME_OLD}
		git pull
	else
		
		git clone "https://opencm:${GIT_PWD}@github.com/CloudifySource/${project}.git"
		pushd ${project}
		git checkout ${BRANCH_NAME_OLD}
	fi

	project_parent_pom_folder=`pwd` 
	
	project_home=`pwd`	


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
		git checkout ${BRANCH_NAME_OLD}
                git pull
        else
                git clone "https://opencm:${GIT_PWD}@github.com/CloudifySource/${project}.git"
                pushd ${project}
		git checkout ${BRANCH_NAME_OLD}
        fi


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

for project in "${CONCATE_PROJECTS_LIST[@]}"
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
#for project in "${TEST_PROJECTS_LIST[@]}"
#do
#	pushd ${project}		
#	exists=`git show-ref refs/heads/${BRANCH_NAME}`
#	if [ -n "$exists" ]; then
#	    	echo "*** ${project} - branch: ${BRANCH_NAME} exists"
#	else
#		echo "*** !!!${project} - branch: ${BRANCH_NAME} does not exist!!!"
#
#	fi
#	popd
#done