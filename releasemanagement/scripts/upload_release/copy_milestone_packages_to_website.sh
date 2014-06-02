#!/bin/bash

source params.sh

##copy gslicense.xml from xap-premium zip to xap-bigdata
#cp -rp ${BUILD_DIR} ${BUILD_DIR}_backup
#pushd ${BUILD_DIR}/xap-premium/1.5
#    PREMIUM_ZIP=`find . -name "*-with-license.zip"`
#    echo "PREMIUM_ZIP="${PREMIUM_ZIP}
#    PREMIUM_UNZIP_DEST=`echo ${PREMIUM_ZIP}| sed 's/\.zip//g'`
#    echo "PREMIUM_UNZIP_DEST="${PREMIUM_UNZIP_DEST}
#    unzip ${PREMIUM_ZIP} -d ${PREMIUM_UNZIP_DEST}
#popd
#pushd ${BUILD_DIR}/xap-bigdata/1.5
#   BIGDATA_ZIP=`find . -name "gigaspaces-xap-premium-*.zip"`
#   echo "BIGDATA_ZIP="${BIGDATA_ZIP} 
#   BIGDATA_UNZIP_DEST=`echo ${BIGDATA_ZIP}| sed 's/\.zip//g'`
#   echo "BIGDATA_UNZIP_DEST="${BIGDATA_UNZIP_DEST}
#   MAIN_ZIP_DIR=gigaspaces-xap-premium-${VERSION}-${MILESTONE}
#   mkdir ${MAIN_ZIP_DIR}
#   cp ${BUILD_DIR}/xap-premium/1.5/${PREMIUM_UNZIP_DEST}/gigaspaces-xap-premium*/gslicense.xml ${MAIN_ZIP_DIR}/
#   zip ${BIGDATA_ZIP} ${MAIN_ZIP_DIR}/gslicense.xml
#   rm -rf ${MAIN_ZIP_DIR}
#popd
#pushd ${BUILD_DIR}/xap-premium/1.5   
#   rm -rf ${PREMIUM_UNZIP_DEST}
#popd


#upload package files to website
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "mkdir -p ~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}/"

#for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi"  | grep -v license | grep -v testsuite | grep -v xap-premium.1.5`; do
for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi"  | grep -v license | grep -v testsuite`; do

  echo Uploading $file to ~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}
  scp -o "StrictHostKeyChecking no" -i ~/.ssh/website $file tempfiles@www.gigaspaces.com:~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}
done
