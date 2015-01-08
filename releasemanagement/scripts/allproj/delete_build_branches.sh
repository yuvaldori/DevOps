#!/bin/bash

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
            if [ -d ".git" ]
            then
                for build_branch in ${BUILD_BRANCHES_LIST}
                do

                        if [[ `git branch -r | grep origin/$build_branch` ]]
                        then
                            echo "Removing $build_branch"
                            git push origin --delete $build_branch
                            exit_on_error
                        fi
                done
            fi
      popd
done
