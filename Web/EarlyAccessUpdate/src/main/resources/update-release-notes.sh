#!/bin/bash

#USAGE:  sh -x ./update-release-notes.sh  jiraUser jiraPass wikiUser wikiPass GS 9.6.1 1,2,3 2013-07-09 9.6.1 9.6.1

JIRA_USER=${1}
JIRA_PASSWORD=${2}
WIKI_USER=${3}
WIKI_PASSWORD=${4}
ISSUE_PROJECT=${5}
ISSUE_FIX_VERSION=${6}
SPRINT_NUMBER=${7}
CREATED_AFTER=${8}
BUILD_VERSION=${9}
SINCE_VERSION=${10}

cd ../../../
mvn exec:java -Dexec.mainClass="ReleaseNotesUpdate" -Dexec.args="${JIRA_USER} ${JIRA_PASSWORD} ${WIKI_USER} ${WIKI_PASSWORD} ${ISSUE_PROJECT} ${ISSUE_FIX_VERSION} ${SPRINT_NUMBER} ${CREATED_AFTER} ${BUILD_VERSION} ${SINCE_VERSION}"