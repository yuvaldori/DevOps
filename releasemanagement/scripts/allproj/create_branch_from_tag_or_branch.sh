#!/bin/bash

function exit_on_error {
    status=$?
    echo "exit code="$status    
    if [ $status != 0 ] ; then
        echo "Failed (exit code $status)" 
        #exit 1
    fi

}
ORIGIN=""
#TAG_NAME=10.0.1_ga_build11824_03_29_2015
if [ "$TAG_NAME" =~ "-build" ]
then
    ORIGIN="origin/"
fi

for dir in `pwd`/*/
do
    dir=${dir%*/}
    r=${dir##*/}
    echo "### Processing repository: $r"
    pushd $r
        if  [ -d ".git" ]
        then
          git checkout master
          git pull --all
          git pull origin master
          git checkout -b $BRANCH_NAME $ORIGIN$TAG_NAME
          exit_on_error

          # push tag to remote
          git push origin $BRANCH_NAME
          exit_on_error
        fi
    popd
done
