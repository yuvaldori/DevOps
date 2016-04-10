#!/bin/bash

source params.sh

DEST_DIR=\~/tempfiles/${VERSION}_patch${PATCH_NUMBER}
echo DEST_DIR=${DEST_DIR}
CLOUDIFY_BUILD_DIR=${REPOSITORY}/cloudify/${VERSION}/build_${BUILD_NUMBER}

XAP_ZIP_FILE="${BUILD_DIR}/xap-premium/1.5/gigaspaces-xap-premium-${VERSION}-ga-b${BUILD_NUMBER}.zip"
CLOUDIFY_FILES="${CLOUDIFY_BUILD_DIR}/cloudify/1.5/*"
DOTNET_FILES="${BUILD_DIR}/xap-premium/dotnet/*-Premium-*.msi"
CPP_FILES="${BUILD_DIR}/gigaspaces-cpp-*.tar.gz"


RN_FILE=Release_Notes_${MAJOR}_${MINOR}_${SERVICEPACK}_patch${PATCH_NUMBER}.doc

ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "mkdir -p ${DEST_DIR}"

#copy release notes file
scp -i ~/.ssh/website ${REPOSITORY}/release_notes/${RN_FILE} tempfiles@www.gigaspaces.com:${DEST_DIR}

#copy package files
case  $PATCH_TYPE  in
      xap)
         scp -i ~/.ssh/website $XAP_ZIP_FILE tempfiles@www.gigaspaces.com:${DEST_DIR}
        ;;
      dotnet)
        scp -i ~/.ssh/website $DOTNET_FILES tempfiles@www.gigaspaces.com:${DEST_DIR}
        ;;
      cpp)
         scp -i ~/.ssh/website $CPP_FILES tempfiles@www.gigaspaces.com:${DEST_DIR}
        ;;
      cloudify)
        scp -i ~/.ssh/website $CLOUDIFY_FILES tempfiles@www.gigaspaces.com:${DEST_DIR}
        ;;

      *)
esac
