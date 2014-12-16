#!/bin/bash

log="`pwd`/diff_master_build-branch.log"
echo "###start `date`" > $log

for dir in ./*/
do		
    dir=${dir%*/}
    dir=${dir##*/}    
    pushd $dir
    	if [ -d ".git" ]
		then			
    		git checkout master
    		git pull
    		echo "### $dir diff" >> $log
    		if [[ "$dir" == *-plugin ]] || [[ "$dir" == *-provider ]]
			then
			    VERSION_BRANCH_NAME="1.1-build"
			else
			    VERSION_BRANCH_NAME="3.1-build"
			fi
    		git diff --name-status origin/master..origin/$VERSION_BRANCH_NAME >> $log 2>&1
    		echo "### end diff" >> $log
    	fi
    popd
done
