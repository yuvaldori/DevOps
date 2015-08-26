#!/bin/bash -x
BRANCH_NAME_FOR_TEST=$(echo $BRANCH_NAME_FOR_TEST)
echo "BRANCH_NAME_FOR_TEST=$BRANCH_NAME_FOR_TEST"
echo "BRANCH_NAME=$BRANCH_NAME"
#VERSION_BRANCH_NAME="$gs_product_version$milestone-build"
echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		exit 1
      fi

}

for dir in `pwd`/*/
do
        dir=${dir%*/}
        repo=${dir##*/}
        
        if [ "$repo" != "examples" ]
	then
		echo "### Processing repository: $repo"
		pushd $repo
			git pull origin master
			
			if [ -n "$BRANCH_NAME_FOR_TEST" ] && [[ `git branch -r | grep origin/$BRANCH_NAME_FOR_TEST` ]]
			then
				if [[ `git branch | grep $BRANCH_NAME_FOR_TEST` ]] 
				then
					git checkout $BRANCH_NAME_FOR_TEST
				else			
					git checkout -b $BRANCH_NAME_FOR_TEST origin/$BRANCH_NAME_FOR_TEST
				fi
				exit_on_error
				git reset --hard origin/$BRANCH_NAME_FOR_TEST
				exit_on_error
			else
				git checkout $BRANCH_NAME
				git reset --hard origin/$BRANCH_NAME
				exit_on_error
				git pull origin $BRANCH_NAME
				exit_on_error
			fi
			
			if [ "$RELEASE_BUILD" == "true" ]
		 	then
	 			if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
	 			then
	 				git checkout $VERSION_BRANCH_NAME
	 				exit_on_error
	 				git reset --hard origin/$VERSION_BRANCH_NAME
	 				exit_on_error
	 			elif [[ `git branch -r | grep origin/$VERSION_BRANCH_NAME` ]]
	 			then
	 				git checkout -b $VERSION_BRANCH_NAME origin/$VERSION_BRANCH_NAME
	 				exit_on_error
	 				git reset --hard origin/$VERSION_BRANCH_NAME
	 				exit_on_error
	 			else
	 				git checkout -b $VERSION_BRANCH_NAME
	 				exit_on_error
	 				git push origin $VERSION_BRANCH_NAME
			 		exit_on_error
			 		XAP_TRUNK_SVN_URL="svn://pc-lab14/SVN/xap"
					BRANCH_FOLDER="$majorVersion_$minorVersion_X"
					SVN_REVISION_NUMBER=`svn info ${XAP_TRUNK_SVN_URL} | grep Revision | awk '{print $2}'`
					svn cp ${XAP_TRUNK_SVN_URL}/trunk/quality ${XAP_TRUNK_SVN_URL}/branches/${BRANCH_FOLDER}/${VERSION_BRANCH_NAME} -m "Create branch ${VERSION_BRANCH_NAME} from ${XAP_TRUNK_SVN_URL}/trunk/quality, revision: ${SVN_REVISION_NUMBER}"
	 			fi
			fi
			sha=$(git rev-parse HEAD)
		 	if [[ -z "$repo_names_sha" ]];then
		 		repo_names_sha='[ "'$repo'":"'$sha'"'	
		 	else
		 		repo_names_sha=$repo_names_sha',"'$repo'":"'$sha'"'
		 	fi
		popd
	fi
	
done
repo_names_sha=$repo_names_sha' ]'
echo $repo_names_sha > repo_names_sha
