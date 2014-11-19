#!/bin/bash

#sudo add-apt-repository ppa:chris-lea/node.js 
#sudo apt-get update
#sudo apt-get -y install nodejs
#sudo npm install -g bower

source ../generic_functions.sh
source ../params.sh

branch_names=()
git checkout master

git fetch -v --dry-run > ../fetch.output 2>&1

IFS=$'\n'; list=($(cat ../fetch.output | grep -v 'up to date' | grep -v 'POST git-upload-pack' | grep -v 'From https' | grep -v 'error:')) ; echo "***list=${list[@]}"
unset IFS

git checkout master
git pull

[ -f ../send.email ] && rm -f ../send.email
[ -f ../branch.names ] && rm -f ../branch.names
[ -d ../tests_resultss ] && rm -rf ../tests_results


if [[ $list ]]
then
  echo "yes" > ../send.email
  sudo npm cache clean
  sudo bower cache clean

  for line in "${list[@]}"
  do
    echo "***line=$line"
    if [[ "$line" =~ "\[new branch\]" ]]
    then
      branch_names+=($(echo "$line" | awk '{ print $4 }'))
    else
      branch_names+=($(echo "$line" | awk '{ print $2 }'))
    fi
  done
  
  IFS=$'\n'; echo "***branch_names=${branch_names[@]}"
  echo "${branch_names[@]}" > ../branch.names
  unset IFS

  for branch in "${branch_names[@]}"
  do
    echo "### Starting tests on $branch"
    git checkout $branch
    
    [ -d dist ] && sudo rm -rf dist
    [ -d node_modules ] && sudo rm -rf node_modules
    [ -d app/bower_components ] && rm -rf app/bower_components

    retry "sudo npm install"
    retry "bower install -f"
    retry "bower update -f"
    run_command "grunt test --no-color"
    mkdir -p ../tests_results
    cp -f test-results.xml ../tests_results
    echo "### Done tests on $branch"
  done
else
  echo "***Everything up-to-date***"
fi

echo "### Clean environment"
git checkout master
git clean -df
git reset --hard origin/master  
#git pull

echo "### Done"
