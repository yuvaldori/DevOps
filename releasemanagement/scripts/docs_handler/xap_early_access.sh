#!/bin/bash

. ./setenv.sh
source params.sh

#API_DOC_VERSION=9.7
#XAP_RELEASE_VERSION=${API_DOC_VERSION}.0
#MILESTONE=m6
#BUILD_NUM=10491

XAP_DIR=gigaspaces-xap-premium-${XAP_RELEASE_VERSION}-${MILESTONE}
XAP_ZIP_FILENAME=${XAP_DIR}-b${BUILD_NUM}.zip
DOTNET_HELP_FILE=gigaspaces-xap.net-${XAP_RELEASE_VERSION}-${MILESTONE}-b${BUILD_NUM}-doc.zip

# LINKS
JAVADOC_LINK=JavaDoc${API_DOC_VERSION}
DOTNETDOC_LINK=dotnetdocs${API_DOC_VERSION}
CPPDOC_LINK=cppdocs${API_DOC_VERSION}
SCALADOC_LINK=scaladocs${API_DOC_VERSION}
MONGOEDSDOC_LINK=mongoeds-docs${API_DOC_VERSION}
CASSANDRA_LINK=cassandra-docs${API_DOC_VERSION}

# DOCS DIRS
JAVA_DOCS_DIR=${XAP_DIR}/docs/xap-javadoc 
DOTNET_DOCS_DIR=${XAP_DIR}/dotnet/docs
CPP_DOCS_DIR=${XAP_DIR}/cpp/docs/html
SCALA_DOCS_DIR=${XAP_DIR}/docs/scaladocs
MONGOEDS_DOCS_DIR=${XAP_DIR}/docs/mongoeds-docs
CASSANDRA_DOCS_DIR=${XAP_DIR}/docs/cassandra-docs

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
	cp -R ${DOC_DIR}//gigaspaces-xap-premium-9.6.2-ga/cpp  ${XAP_DIR} 
	pushd ${XAP_DIR}/cpp
		find .  -name '*.html' -exec sed -i "s/XAP 9.7/XAP ${MAJOR_NEW}.${MINOR_NEW}/g" '{}' \; 
	popd

	###### SCALA API ######	
	unzip -d ${XAP_DIR}/docs ${XAP_DIR}/docs/openspaces-scala-scaladocs.zip

	###### MONGOEDS API #####
	mkdir  ${MONGOEDS_DOCS_DIR}	
	unzip -d ${MONGOEDS_DOCS_DIR} ${XAP_DIR}/docs/mongo-datasource.zip

	###### CASSANDRA API #####
	if [ -f ${XAP_DIR}/docs/xap-cassandra.zip ]; then
		mkdir  ${CASSANDRA_DOCS_DIR}	
		unzip -d ${CASSANDRA_DOCS_DIR} ${XAP_DIR}/docs/xap-cassandra.zip
	fi

	###### REMOVE LINKS ######
	rm ${JAVADOC_LINK} ${DOTNETDOC_LINK} ${CPPDOC_LINK} ${SCALADOC_LINK} ${MONGOEDSDOC_LINK} ${CASSANDRA_LINK}

	###### CREATE LINKS ######
	ln -s ${JAVA_DOCS_DIR} ${JAVADOC_LINK}
	ln -s ${DOTNET_DOCS_DIR} ${DOTNETDOC_LINK}
	ln -s ${CPP_DOCS_DIR} ${CPPDOC_LINK}
	ln -s ${SCALA_DOCS_DIR} ${SCALADOC_LINK}
	ln -s ${MONGOEDS_DOCS_DIR} ${MONGOEDSDOC_LINK}
	if [ -f ${XAP_DIR}/docs/xap-cassandra.zip ]; then
		ln -s ${CASSANDRA_DOCS_DIR} ${CASSANDRA_LINK}
	fi


popd

