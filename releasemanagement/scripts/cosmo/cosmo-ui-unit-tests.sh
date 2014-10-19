#!/bin/bash -x

#sudo add-apt-repository ppa:chris-lea/node.js 
#sudo apt-get update
#sudo apt-get -y install nodejs
#sudo npm install -g bower

source generic_functions.sh

function retry
{
  nTrys=0
  maxTrys=10
  status=256
  until [ $status == 0 ] ; do
  echo "*** Running $1"
  $1
  status=$?
  nTrys=$(($nTrys + 1))
  if [ $nTrys -gt $maxTrys ] ; then
  echo "Number of re-trys exceeded. Exit code: $status"
  exit $status
  fi
  if [ $status != 0 ] ; then
  echo "Failed (exit code $status)... retry $nTrys"
  sleep 15
  fi
  done
}

branch_names=()
git fetch -v --dry-run >fetch.output 2>&1
IFS=$'\n'; list=($(cat fetch.output | grep -v 'up to date' | grep -v 'From https')) ; echo 'list=${list[*]}'
if [[ $list ]]
then
  for line in "${list[@]}"
  do
    echo line=$line
    if [[ $line =~ '[new branch]' ]]
    then
      #echo "[new branch]"
      #echo $line | awk '{ print $4 }'
      branch_names+=($(echo $line | awk '{ print $4 }'))
    else
      #echo "stam"
      #echo $line | awk '{ print $2 }'
      branch_names+=($(echo $line | awk '{ print $2 }'))
    fi
  done
IFS=$'\n'; echo 'branch_names=${branch_names[*]}'

  for branch in "${branch_names[@]}"
  do
    git checkout $branch
    sudo rm -rf node_modules/ 
    rm -rf app/bower_components/
    #retry "sudo npm install"
    #retry "bower install -f"
    #retry "bower update -f"
    #run_command "grunt test"
 "sudo npm install"
 "bower install -f"
 "bower update -f"
 "grunt test"
  done
else
  echo "Everything up-to-date"
fi
  
