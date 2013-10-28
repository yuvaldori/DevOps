#!/bin/bash

. ./setenv.sh

API_DOC_VERSION=9.6
XAP_RELEASE_VERSION=${API_DOC_VERSION}.0
MILESTONE=rc
BUILD_NUM=9486

XAP_DIR=gigaspaces-xap-premium-${XAP_RELEASE_VERSION}-${MILESTONE}
XAP_ZIP_FILENAME=${XAP_DIR}-b${BUILD_NUM}.zip
DOTNET_HELP_FILE=gigaspaces-xap.net-${XAP_RELEASE_VERSION}-${MILESTONE}-b${BUILD_NUM}-doc.zip

# LINKS
JAVADOC_LINK=JavaDoc${API_DOC_VERSION}
DOTNETDOC_LINK=dotnetdocs${API_DOC_VERSION}
CPPDOC_LINK=cppdocs${API_DOC_VERSION}

# DOCS DIRS
JAVA_DOCS_DIR=${XAP_DIR}/docs/xap-javadoc 
DOTNET_DOCS_DIR=${XAP_DIR}/dotnet/docs
CPP_DOCS_DIR=${XAP_DIR}/cpp/docs/html

cp ${XAP_EA_DIR}/${XAP_RELEASE_VERSION}/${MILESTONE}/${XAP_ZIP_FILENAME} ${DOC_DIR}

pushd ${DOC_DIR} 

rm -rf ${XAP_DIR} 

unzip ${XAP_ZIP_FILENAME}

####### JAVA API ######
unzip -d ${JAVA_DOCS_DIR} ${XAP_DIR}/docs/xap-javadoc.zip  

###### DOTNET API #####
mkdir  ${XAP_DIR}/dotnet
mkdir  ${DOTNET_DOCS_DIR}
cp  ${XAP_EA_DIR}/${XAP_RELEASE_VERSION}/${MILESTONE}/${DOTNET_HELP_FILE} ${DOTNET_DOCS_DIR}
unzip -d ${DOTNET_DOCS_DIR} ${DOTNET_DOCS_DIR}/${DOTNET_HELP_FILE}
mv ${DOTNET_DOCS_DIR}/Index.html ${DOTNET_DOCS_DIR}/index.html

###### CPP API #####
cp -R ${DOC_DIR}/gigaspaces-xap-premium-9.5.0-m4/cpp  ${XAP_DIR} 


###### REMOVE LINKS ######
rm ${JAVADOC_LINK} ${DOTNETDOC_LINK} ${CPPDOC_LINK}

###### CREATE LINKS ######
ln -s ${JAVA_DOCS_DIR} ${JAVADOC_LINK}
ln -s ${DOTNET_DOCS_DIR} ${DOTNETDOC_LINK}
ln -s ${CPP_DOCS_DIR} ${CPPDOC_LINK}

popd

