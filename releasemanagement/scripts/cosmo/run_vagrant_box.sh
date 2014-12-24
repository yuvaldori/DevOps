#!/bin/bash

source ../../ec2dev_credentials.sh
source /etc/environment

#python nightly-builder.py

pushd /cloudify
  wget http://cloudify-nightly-vagrant.s3-website-eu-west-1.amazonaws.com/Vagrantfile
  vagrant_box_name=$(basename $(grep -o box_url.* Vagrantfile | grep -o \".*\" | sed -e "s/\"//g"))
  wget http://cloudify-nightly-vagrant.s3-website-eu-west-1.amazonaws.com/$vagrant_box_name
popd

