#!/bin/bash -x
BRANCH_NAME_FOR_TEST=$(echo $BRANCH_NAME_FOR_TEST)
echo "BRANCH_NAME_FOR_TEST=$BRANCH_NAME_FOR_TEST"
echo "BRANCH_NAME=$BRANCH_NAME"
VERSION_BRANCH_NAME="$gs_product_version$milestone-build"
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
 			fi
		fi
		sha=$(git rev-parse HEAD)
	 	if [[ -z "$repo_names_sha" ]];then
	 		repo_names_sha='[ "'$repo'":"'$sha'"'	
	 	else
	 		repo_names_sha=$repo_names_sha',"'$repo'":"'$sha'"'
	 	fi
	popd
	
done
repo_names_sha=$repo_names_sha' ]'
echo $repo_names_sha > repo_names_sha
