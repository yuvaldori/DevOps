#!/bin/bash

function  exit_on_error {
    status=$?
    echo "exit code="$status    
    if [ $status != 0 ] ; then
        echo "Failed (exit code $status)" 
        #exit 1
    fi

}

old_branch_name="10.1.1-patch1"
new_branch_name="10.1.1patch1-build"

for dir in `pwd`/*/
do
    dir=${dir%*/}
    repo=${dir##*/}
      
    if [ "$repo" != "examples" ]
	then

        echo "### Processing repository: $repo"
        pushd $repo
            if [ -d ".git" ]
            then
                if [[ ! `git branch | grep "$old_branch_name"` ]]
                then
                    git checkout -b $old_branch_name origin/$old_branch_name
                fi
                git branch -m $old_branch_name $new_branch_name
                exit_on_error
                git push origin :$old_branch_name
                exit_on_error
                git push origin $new_branch_name
                exit_on_error
            fi
        popd
    fi
done
