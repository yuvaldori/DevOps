#!/bin/bash

source ../../credentials.sh
source /etc/environment

python nightly-builder.py

sudo chown tgrid -R /cloudify
pushd /cloudify
  wget http://cloudify-nightly-vagrant.s3.amazonaws.com/Vagrantfile
  vagrant_box_name=$(basename $(grep -o box_url.* Vagrantfile | grep -o \".*\" | sed -e "s/\"//g"))
  wget http://cloudify-nightly-vagrant.s3.amazonaws.com/$vagrant_box_name
popd

