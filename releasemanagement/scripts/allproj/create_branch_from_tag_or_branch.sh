#!/bin/bash

function exit_on_error {
    status=$?
    echo "exit code="$status    
    if [ $status != 0 ] ; then
        echo "Failed (exit code $status)" 
        #exit 1
    fi

}

#TAG_NAME=10.0.1_ga_build11824_03_29_2015

for dir in `pwd`/*/
do
    dir=${dir%*/}
    r=${dir##*/}
    echo "### Processing repository: $r"
    pushd $r
        if  [ -d ".git" ]
        then
          git checkout -b $BRANCH_NAME $TAG_NAME
          exit_on_error

          # push tag to remote
          git push origin $BRANCH_NAME
          exit_on_error
        fi
    popd
done
