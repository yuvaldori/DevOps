#!/bin/bash -x

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)" 
		exit 1
      fi

}

temp_branch_name="release_tag"
tag_name="10.1.0_ga_build12600_03_30_2015"

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

zip -r 10.1.0_source_code.zip ./* -x '*.sh' -x 'repo_names_sha' -x 'devops/*' -x 'examples/*' -x 'xap-session-sharing-manager-itests/*' -x 'xap-spring-data/*' -x 'xap-example-*/*' -x '*/.git/*' -x '*/.qbcache/*' -x '*/.gitignore'
