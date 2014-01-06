#!/bin/bash

local_gitrepo=/opt/git-repo
local_cloudify_repo=$local_gitrepo/cloudify
local_openspaces_repo=$local_gitrepo/openspaces
local_openspaces_scala_repo=$local_gitrepo/openspaces-scala
local_gigaspaces_repo=$local_gitrepo/gigaspaces
local_gigaspaces_dotnet_repo=$local_gitrepo/gigaspaces-dotnet
local_gs_ui_repo=$local_gitrepo/gs-ui
local_gs_qa_repo=$local_gitrepo/QA

echo "push start `date`"

#push cloudify
#cd $local_cloudify_repo
#git svn rebase
#git push  -f -u origin master

#push openspaces
pushd $local_openspaces_repo
	git svn rebase
	git push  -f -u origin master
popd

#push local_openspaces_scala_repo 
pushd $local_openspaces_scala_repo
	git svn rebase
	git push  -f -u origin master
popd

#push local_gigaspacesi_repo
pushd $local_gigaspaces_repo
	git svn rebase
	git push  -f -u origin master
popd

pushd $local_gigaspaces_dotnet_repo
	git svn rebase
	git push  -f -u origin master
popd
pushd $local_gs_qa_repo
	git svn rebase
	git push  -f -u origin master
popd

pushd $local_gs_ui_repo
git svn rebase
git push  -f -u origin master
popd

pushd $local_gs_qa_repo
	git svn rebase
	git push  -f -u origin master
popd

echo "push end `date`"
echo 
echo

