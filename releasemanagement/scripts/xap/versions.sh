#!/bin/bash -x

for dir in `pwd`/*/
    do
        dir=${dir%*/}
        repo=${dir##*/}
	if [ "$repo" != "examples" ]
	then	
		echo "### Processing repository: $repo"
		pushd $repo
			if [[ `git branch -r | grep origin/$BRANCH_NAME` ]]
	 		then
				if [[ `git branch | grep $BRANCH_NAME` ]] 
				then
					git checkout $BRANCH_NAME
				else			
					git checkout -b $BRANCH_NAME origin/$BRANCH_NAME
				fi
				#exit_on_error
				git reset --hard origin/$VERSION_BRANCH_NAME
				#exit_on_error
			else
				git checkout master
				git reset --hard origin/master
			fi
		popd
	fi
    done

