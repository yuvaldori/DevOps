#!/bin/bash

function  exit_on_error {
    status=$?
    echo "exit code="$status    
    if [ $status != 0 ] ; then
        echo "Failed (exit code $status)" 
        #exit 1
    fi

}

TAGS_LIST="3.2rc 1.2rc"

for dir in `pwd`/*/
do
      dir=${dir%*/}
      repo=${dir##*/}

          echo "### Processing repository: $repo"
          pushd $repo
            if [ -d ".git" ]
            then
                for tagname in ${TAGS_LIST}
                do

                        if [[ `git tag | grep $tagname` ]]
                        then
                            echo "Removing $tagname"
                            git tag -d tagname
                            git push origin :tagname
                            exit_on_error
                        fi
                done
            fi
      popd
done
