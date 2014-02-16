#!/bin/bash

MAJOR_VERSION=9
VERSION=${MAJOR_VERSION}.7.0
BUILD_NUMBER=10496
MILESTONE=ga
REPOSITORY=/export/builds
BUILD_DIR=${REPOSITORY}/${VERSION}/build_${BUILD_NUMBER}

ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "mkdir -p ~/download_files/${MAJOR_VERSION}/${VERSION}/"

#for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi"  | grep -v license | grep -v testsuite | grep -v xap-premium.1.5`; do
for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi"  | grep -v license | grep -v testsuite`; do
  echo Uploading $file to ~/download_files/${MAJOR_VERSION}/${VERSION}/
  scp -i ~/.ssh/website $file tempfiles@www.gigaspaces.com:~/download_files/${MAJOR_VERSION}/${VERSION}/
done
