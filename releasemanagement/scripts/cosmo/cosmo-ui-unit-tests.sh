#!/bin/bash -x

#sudo add-apt-repository ppa:chris-lea/node.js 
#sudo apt-get update
#sudo apt-get -y install nodejs
#sudo npm install -g bower

source generic_functions.sh

branch_names=()

git fetch -v --dry-run > fetch.output 2>&1

IFS=$'\n'; list=($(cat fetch.output | grep -v 'up to date' | grep -v 'POST git-upload-pack' | grep -v 'From https')) ; echo "list=${list[@]}"
unset IFS

if [[ $list ]]
then
  
  sudo npm cache clean
  sudo bower cache clean

  for line in "${list[@]}"
  do
    echo line=$line
    if [[ $line =~ '[new branch]' ]]
    then
      branch_names+=($(echo $line | awk '{ print $4 }'))
    else
      branch_names+=($(echo $line | awk '{ print $2 }'))
    fi
  done
  
  IFS=$'\n'; echo "branch_names=${branch_names[@]}"
  unset IFS

  for branch in "${branch_names[@]}"
  do
    git checkout $branch
    sudo rm -rf node_modules/ 
    rm -rf app/bower_components/
    retry "sudo npm install"
    retry "bower install -f"
    retry "bower update -f"
    run_command "grunt test"
    git pull
  done
  git pull
else
  echo "***Everything up-to-date***"
fi
  
