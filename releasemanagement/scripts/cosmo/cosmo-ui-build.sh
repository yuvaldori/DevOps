#!/bin/bash

source ../retry.sh

function run_command 
{
  
	status=256
   
  	echo "*** Running $1"      
   	$1
  	status=$?   
    
     	if [ $status != 0 ] ; then
            echo "Failed with exit code $status"
            exit $status
      	fi   
}

if [ -d dist ]
then
	sudo rm -rf dist
fi
retry "npm install"
retry "bower install -force"
retry "bower update -force"
run_command "grunt build"
pushd dist
	run_command "npm install --production"
	run_command "npm pack"
#popd
