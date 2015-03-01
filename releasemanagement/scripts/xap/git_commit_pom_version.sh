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
			git add -u \*pom.xml
			git commit -m 'Bump version' \*pom.xml
			
			if [ -n "$BRANCH_NAME_FOR_TEST" ] && [[ `git branch -r | grep origin/$BRANCH_NAME_FOR_TEST` ]]
			then
				 git push origin $BRANCH_NAME_FOR_TEST
				 exit_on_error
			elif [ "$RELEASE_BUILD" == "true" ]
		 	then
	 				git push origin $VERSION_BRANCH_NAME
			 		exit_on_error
			else
				git push origin $BRANCH_NAME
				exit_on_error
			fi
		popd
done