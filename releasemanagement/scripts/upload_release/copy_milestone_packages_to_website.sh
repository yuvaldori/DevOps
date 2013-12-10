#!/bin/bash

source params.sh

REPOSITORY=/export/builds
BUILD_DIR=${REPOSITORY}/${VERSION}/build_${BUILD_NUMBER}

#copy gslicense.xml from xap-premium zip to xap-bigdata
cp -rp ${BUILD_DIR} ${BUILD_DIR}_backup
pushd ${BUILD_DIR}/xap-premium/1.5
   PREMIUM_ZIP=`find . -name "*-with-license.zip"`
   echo "PREMIUM_ZIP="${PREMIUM_ZIP}
   PREMIUM_UNZIP_DEST=`echo ${PREMIUM_ZIP}| sed 's/\.zip//g'`
   echo "PREMIUM_UNZIP_DEST="${PREMIUM_UNZIP_DEST}
   unzip ${PREMIUM_ZIP} -d ${PREMIUM_UNZIP_DEST}
popd
pushd ${BUILD_DIR}/xap-bigdata/1.5
   BIGDATA_ZIP=`find . -name "gigaspaces-xap-premium-*.zip"`
   echo "BIGDATA_ZIP="${BIGDATA_ZIP} 
   BIGDATA_UNZIP_DEST=`echo ${BIGDATA_ZIP}| sed 's/\.zip//g'`
   echo "BIGDATA_UNZIP_DEST="${BIGDATA_UNZIP_DEST}
   unzip ${BIGDATA_ZIP} -d ${BIGDATA_UNZIP_DEST}
popd

cp -f ${BUILD_DIR}/xap-premium/1.5/${PREMIUM_UNZIP_DEST}/gigaspaces-xap-premium*/gslicense.xml ${BUILD_DIR}/xap-bigdata/1.5/${BIGDATA_UNZIP_DEST}/gigaspaces-xap-premium*/

pushd ${BUILD_DIR}/xap-premium/1.5   
   rm -rf ${PREMIUM_UNZIP_DEST}
popd
pushd ${BUILD_DIR}/xap-bigdata/1.5
   rm -f ${BIGDATA_ZIP}
   zip -r ${BIGDATA_ZIP} ${BIGDATA_UNZIP_DEST} 
   rm -rf ${BIGDATA_UNZIP_DEST}
popd

#upload package files to website
ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "mkdir -p ~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}/"

for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi"  | grep -v license | grep -v testsuite | grep -v xap-premium.1.5`; do
  echo Uploading $file to ~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}
  scp -i ~/.ssh/website $file tempfiles@www.gigaspaces.com:~/tempfiles/downloads/EarlyAccess/xap/${VERSION}/${MILESTONE}
done
