#!/bin/bash -x
  
  for dir in `pwd`/*/
  do
          dir=${dir%*/}
          repo=${dir##*/}
  		
  	echo "### Processing repository: $repo"
  	pushd $repo
  	  [ -d ".git" ] && git clean -dfx
    popd
  done
