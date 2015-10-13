#!/bin/bash -x

# run command - ./escrow.sh > log.log 2>&1

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
                echo "Failed (exit code $status)" 
      fi

}

temp_branch_name="release_tag"
tag_name="10.2.0_ga_build13800_07_28_2015"

for dir in `pwd`/*/
do
    dir=${dir%*/}
    repo=${dir##*/}

      if [ "$repo" != "examples" ] && [ "$repo" != "xap-session-sharing-manager-itests" ] && [ "$repo" != "xap-spring-data" ] &&  [[ ! "$repo" =~ "xap-example" ]]
      then
        echo "### Processing repository: $repo"
        pushd $repo
          git checkout master
          git pull origin master
          git branch | grep $temp_branch_name && git branch -D $temp_branch_name
          git checkout -b $temp_branch_name tags/$tag_name
          exit_on_error
          git --no-pager log -1
        popd
      fi
done

( find . -type d -name ".git" \
  && find . -name ".gitignore" \
  && find . -name ".gitmodules" ) | xargs rm -rf
  
