#!/bin/bash -x

XAP_TRUNK_SVN_URL="svn://pc-lab14/SVN/xap/trunk/quality"
BRANCH_FOLDER="10_2_X"
BRANCH_NAME="10.2.0m2-build"
SVN_REVISION_NUMBER=`svn info ${XAP_TRUNK_SVN_URL} | grep Revision | awk '{print $2}'`
svn cp ${XAP_TRUNK_SVN_URL} svn://svn-srv/SVN/xap/branches/${BRANCH_FOLDER}/${BRANCH_NAME} -m "Create branch ${BRANCH_NAME} from ${XAP_TRUNK_SVN_URL}, revision: ${SVN_REVISION_NUMBER}"
