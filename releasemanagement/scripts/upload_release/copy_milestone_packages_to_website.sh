#!/bin/bash

VERSION=9.7.0
BUILD_NUMBER=10484
MILESTONE=m3
REPOSITORY=/export/builds
BUILD_DIR=${REPOSITORY}/${VERSION}/build_${BUILD_NUMBER}

ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "mkdir -p ~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}/"

for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi"  | grep -v license | grep -v testsuite | grep -v xap-premium.1.5`; do
  echo Uploading $file to ~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}
  scp -i ~/.ssh/website $file tempfiles@www.gigaspaces.com:~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}
done
