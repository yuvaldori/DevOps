#!/bin/bash

function exit_on_error {
    status=$?
    echo "exit code="$status    
    if [ $status != 0 ] ; then
        echo "Failed (exit code $status)" 
        #exit 1
    fi

}

#TAG_NAME=10.1.1_ga_build12800_04_28_2015

for dir in `pwd`/*/
do
    dir=${dir%*/}
    repo=${dir##*/}
    
    if [ "$repo" != "examples" ]
	  then
      echo "### Processing repository: $repo"
      pushd $repo
          if  [ -d ".git" ]
          then
            # recreate tag locally
            git tag -f $TAG_NAME
            exit_on_error

            # push tag to remote
            git push -f origin tag $TAG_NAME
            exit_on_error
          fi
      fi
      
    popd
done
