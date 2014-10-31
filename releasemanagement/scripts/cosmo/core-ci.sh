#!/bin/bash -x

source generic_functions.sh
branch_names=()
git checkout master
git fetch -v --dry-run > fetch.output 2>&1
IFS=$'\n'; list=($(cat fetch.output | grep -v 'up to date' | grep -v 'POST git-upload-pack' | grep -v 'From https')) ; echo "***list=${list[@]}"
unset IFS
git checkout master
git pull

[ -f send.email ] && rm -f send.email
[ -f branch.names ] && rm -f branch.names

if [[ $list ]]
then
    #echo "yes" > send.email

    for line in "${list[@]}"
    do
      echo "***line=$line"
      if [[ "$line" =~ "\[new branch\]" ]]
      then
        branch_names+=$(echo "$line" | awk '{ print $4 }')" "
      else
        commit=$(echo "$line" | awk '{ print $1 }')
        echo "***commit=$commit"
        echo "***files=$(git show --name-only $commit)"
        if [[ $(git show --name-only $commit | grep 'core/\|openspaces/') ]]
        then
          echo "***line=$line"
          echo "***branch_names=$branch_names"
          branch_names+=$(echo "$line" | awk '{ print $2 }')
        else
          echo "### Everything up-to-date"
        fi
      fi
    done
    IFS=$'\n'; echo "***branch_names=${branch_names[@]}"
    echo "${branch_names[@]}" > branch.names
    unset IFS
    for branch in "${branch_names[@]}"
    do
      echo "JAVA_HOME=$JAVA_HOME"
      export JAVA_HOME=$JAVA_HOME
      ant_params='-Dnew.build.number="$new.build.number" -Dbuild.type="$build.type" -Dgs.product.version="$gs.product.version" -Dtgrid.suite.target-jvm="$tgrid.suite.target-jvm" -DbuildDate-jvm="$buildDate" -Dcvs.root="$cvs.root" -Dgs.internal.systems.not.available="$gs.internal.systems.not.available -Dbuild.qa.suite.type="$build.qa.suite.type" -Dtgrid.suite.factory-class="$tgrid.suite.factory-class" '
      git checkout $branch
      pushd core/tools
        #build runtimes and openspaces
        echo "ant -f quickbuild.xml ciCompilation $ant_params"
        ant -f quickbuild.xml ciCompilation $ant_params
        #run unit tests
        ant -f quickbuild.xml ciTests $ant_params
      popd
    done
else
    echo "### Everything up-to-date"
fi


echo "### Done"
