#!/bin/bash

USER=$1
PASSWORD=$2
OLD_MILESTONE=$3
NEW_MILESTONE=$4
OLD_BUILD_NUMBER=$5
NEW_BUILD_NUMBER=$6

cd ../../../
mvn exec:java -Dexec.mainClass="EarlyAccessUpdate" -Dexec.args="${USER} ${PASSWORD} ${OLD_MILESTONE} ${NEW_MILESTONE} ${OLD_BUILD_NUMBER} ${NEW_BUILD_NUMBER}"

