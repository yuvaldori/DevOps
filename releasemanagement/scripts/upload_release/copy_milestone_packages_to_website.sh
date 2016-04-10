#!/bin/bash

source params.sh

#upload package files to website
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "mkdir -p ~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}/"

for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi" -o -name "*.rpm"  | grep -v testsuite`; do

  echo Uploading $file to ~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}
  scp -o "StrictHostKeyChecking no" -i ~/.ssh/website $file tempfiles@www.gigaspaces.com:~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}
done
