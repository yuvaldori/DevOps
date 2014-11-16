#!/bin/bash -x

echo "BRANCH_NAME_FOR_TEST=$BRANCH_NAME_FOR_TEST_FOR_TEST"

for dir in `pwd`/*/
    do
        dir=${dir%*/}
        repo=${dir##*/}
	if [ "$repo" != "examples" ]
	then	
		echo "### Processing repository: $repo"
		pushd $repo
			if [[ `git branch -r | grep origin/$BRANCH_NAME_FOR_TEST` ]]
	 		then
				if [[ `git branch | grep $BRANCH_NAME_FOR_TEST` ]] 
				then
					git checkout $BRANCH_NAME_FOR_TEST
				else			
					git checkout -b $BRANCH_NAME_FOR_TEST origin/$BRANCH_NAME_FOR_TEST
				fi
				#exit_on_error
				git reset --hard origin/$BRANCH_NAME_FOR_TEST
				#exit_on_error
			else
				git checkout master
				git reset --hard origin/master
			fi
			git pull
		popd
	fi
    done

