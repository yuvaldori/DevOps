#!/bin/bash

source ../generic_functions.sh

[ -d dist ] && sudo rm -rf dist
[ -d node_modules ] && sudo rm -rf node_modules
[ -d app/bower_components ] && rm -rf app/bower_components

fromdos ~/.npm/connect/2.7.11/package/package.json
fromdos ~/.npm/ncp/0.4.2/package/package.json
fromdos ~/.npm/underscore.string/2.2.1/package/package.json

sudo npm cache clean
sudo bower cache clean

retry "npm install"

if [ $(basename `pwd`) = "cosmo-ui" ]
then
	retry "bower install -f"
	retry "bower update -f"
fi

#run_command "grunt build"
run_command "grunt --no-color"

if [ $(basename `pwd`) = "cosmo-grafana" ]
then
	cp -fp package.json dist
fi

pushd dist
	if [ $(basename `pwd`) = "cosmo-ui" ]
	then
		echo '{' > views/versionDetails.html
		echo '    "revision": "'$REVISION'",' >> views/versionDetails.html
		echo '    "buildVersion": "'$BUILD_NUM'",' >> views/versionDetails.html
		echo '    "buildId": "'$BUILD_ID'",' >> views/versionDetails.html
		echo '    "configurationName": "'$CONFIGURATION_NAME'",' >> views/versionDetails.html
		echo '    "timestamp": "'`date +%T`'",' >> views/versionDetails.html
		echo '    "date": "'`date +'%d/%m/%Y'`'"' >> views/versionDetails.html
		echo '}' >> views/versionDetails.html

	fi
	run_command "npm install --production"
	run_command "npm pack"
#popd
