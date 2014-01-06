#!/bin/bash

. ./setenv.sh
source params.sh

#MAJOR_VERSION=9
#API_DOC_VERSION=${MAJOR_VERSION}.6
#XAP_RELEASE_VERSION=${API_DOC_VERSION}.2
#MILESTONE=ga
#BUILD_NUM=9900

XAP_DIR=gigaspaces-xap-premium-${XAP_RELEASE_VERSION}-${MILESTONE}
XAP_ZIP_FILENAME=${XAP_DIR}-b${BUILD_NUM}.zip
DOTNET_HELP_FILE=gigaspaces-xap.net-${XAP_RELEASE_VERSION}-${MILESTONE}-b${BUILD_NUM}-doc.zip

# LINKS
JAVADOC_LINK=JavaDoc${API_DOC_VERSION}
DOTNETDOC_LINK=dotnetdocs${API_DOC_VERSION}
CPPDOC_LINK=cppdocs${API_DOC_VERSION}
SCALADOC_LINK=scaladocs${API_DOC_VERSION}

# DOCS DIRS
JAVA_DOCS_DIR=${XAP_DIR}/docs/xap-javadoc 
DOTNET_DOCS_DIR=${XAP_DIR}/dotnet/docs
CPP_DOCS_DIR=${XAP_DIR}/cpp/docs/html
SCALA_DOCS_DIR=${XAP_DIR}/docs/scaladocs

cp ${XAP_RELEASE_DOWNLOAD_DIR}/${MAJOR_VERSION}/${XAP_RELEASE_VERSION}/${XAP_ZIP_FILENAME} ${DOC_DIR}

pushd ${DOC_DIR} 

	rm -rf ${XAP_DIR} 

	unzip ${XAP_ZIP_FILENAME}

	####### JAVA API ######
	unzip -d ${JAVA_DOCS_DIR} ${XAP_DIR}/docs/xap-javadoc.zip  

	###### DOTNET API #####
	mkdir  ${XAP_DIR}/dotnet
	mkdir  ${DOTNET_DOCS_DIR}
	cp  ${XAP_RELEASE_DOWNLOAD_DIR}/${MAJOR_VERSION}/${XAP_RELEASE_VERSION}/${DOTNET_HELP_FILE} ${DOTNET_DOCS_DIR}
	unzip -d ${DOTNET_DOCS_DIR} ${DOTNET_DOCS_DIR}/${DOTNET_HELP_FILE}
	mv ${DOTNET_DOCS_DIR}/Index.html ${DOTNET_DOCS_DIR}/index.html

	###### CPP API #####
	# C++ documentatin should be copied from the previous version
	# Note: sometimes some changes must be applied. For example: 
	# if new version is published, like 9.7.0, the C++ documentation version
	# must be changed from 9.6 to 9.7 by running following command within ${XAP_DIR}/cpp folder:
	# find .  -name '*.html' -exec sed -i "s/XAP 9.6/XAP 9.7/g" '{}' \; 

	cp -R ${DOC_DIR}/gigaspaces-xap-premium-${PREVIOUS_VERSION}/cpp  ${XAP_DIR} 
	pushd ${XAP_DIR}/cpp
		find .  -name '*.html' -exec sed -i "s/XAP ${MAJOR_OLD}.${MINOR_OLD}/XAP ${MAJOR_NEW}.${MINOR_NEW}/g" '{}' \; 
	popd
	
	###### SCALA API ######
	unzip -d ${XAP_DIR}/docs ${XAP_DIR}/docs/openspaces-scala-scaladocs.zip

	###### REMOVE LINKS ######
	rm ${JAVADOC_LINK} ${DOTNETDOC_LINK} ${CPPDOC_LINK} ${SCALADOC_LINK}

	###### CREATE LINKS ######
	ln -s ${JAVA_DOCS_DIR} ${JAVADOC_LINK}
	ln -s ${DOTNET_DOCS_DIR} ${DOTNETDOC_LINK}
	ln -s ${CPP_DOCS_DIR} ${CPPDOC_LINK}
	ln -s ${SCALA_DOCS_DIR} ${SCALADOC_LINK}

popd


