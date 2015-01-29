#!/bin/bash

source ../../credentials.sh
source /etc/environment

function  exit_on_error {
      status=$?
      echo "exit code="$status    
      if [ $status != 0 ] ; then
         	echo "Failed (exit code $status)"
		      exit 1
      fi

}

python nightly-builder.py
exit_on_error

sudo chown tgrid -R /cloudify
pushd /cloudify
  wget http://cloudify-nightly-vagrant.s3.amazonaws.com/Vagrantfile
  vagrant_box_name=$(basename $(grep -o box_url.* Vagrantfile | grep -o \".*\" | sed -e "s/\"//g"))
  wget http://cloudify-nightly-vagrant.s3.amazonaws.com/$vagrant_box_name
popd

