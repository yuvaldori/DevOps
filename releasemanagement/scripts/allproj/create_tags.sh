#!/bin/bash

function  exit_on_error {
    status=$?
    echo "exit code="$status    
    if [ $status != 0 ] ; then
        echo "Failed (exit code $status)" 
        exit 1
    fi

}

TAG_NAME=10.1.0_m9_build12590_01_12_2015
  
for dir in `pwd`/*/
do
    dir=${dir%*/}
    repo=${dir##*/}
    echo "### Processing repository: $r"
    pushd $r
		
		# recreate tag locally
    git tag -f $TAG_NAME
    exit_on_error
      	
    # push tag to remote
		git push -f origin tag $TAG_NAME
		exit_on_error
	popd
done
