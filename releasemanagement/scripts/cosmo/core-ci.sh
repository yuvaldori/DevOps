#!/bin/bash -x

source ../generic_functions.sh
source ../params.sh

echo 'new.build.number=$new.build.number'
echo 'build.type=$build.type'

branch_names=()
git checkout master

git fetch -v --dry-run
if [ $? != 0 ] ; then
    rm -rf cosmo-ui/
    git clone https://opencm:${GIT_PWD}@github.com/Gigaspaces/xap.git
fi

git fetch -v --dry-run > fetch.output 2>&1
IFS=$'\n'; list=($(cat fetch.output | grep -v 'up to date' | grep -v 'POST git-upload-pack' | grep -v 'From https' | grep -v 'error:')) ; echo "***list=${list[@]}"
unset IFS
git checkout master
git pull

[ -f send.email ] && rm -f send.email
[ -f branch.names ] && rm -f branch.names

if [[ $list ]]
then
    echo "yes" > send.email
    for line in "${list[@]}"
    do
      echo "***line=$line"
      if [[ "$line" =~ "\[new branch\]" ]]
      then
        branch_names+=($(echo "$line" | awk '{ print $4 }'))
      else
        commit=$(echo "$line" | awk '{ print $1 }')
        echo "***commit=$commit"
        echo "***files=$(git show --name-only $commit)"
        if [[ $(git show --name-only $commit | grep 'core/\|openspaces/') ]]
        then
          branch_names+=($(echo "$line" | awk '{ print $2 }'))
        else
          echo "### Everything up-to-date"
        fi
      fi
    done
    IFS=$'\n'; echo "***branch_names=${branch_names[@]}"
    echo "${branch_names[@]}" > branch.names
    unset IFS
    for branch in "${branch_names[@]}"
    do
      echo "JAVA_HOME=$JAVA_HOME"
      export JAVA_HOME=$JAVA_HOME
      ant_params='-Dnew.build.number="$new.build.number" -Dbuild.type="$build.type" -Dgs.product.version="$gs.product.version" -Dtgrid.suite.target-jvm="$tgrid.suite.target-jvm" -DbuildDate-jvm="$buildDate" -Dcvs.root="$cvs.root" -Dgs.internal.systems.not.available="$gs.internal.systems.not.available" -Dbuild.qa.suite.type="$build.qa.suite.type" -Dtgrid.suite.factory-class="$tgrid.suite.factory-class" -Dtgrid.suite.launcher-class="$tgrid.suite.launcher-class" -Dpermutation.file.path="$permutation.file.path" -Dbuild.qa.suite.version="$build.qa.suite.version" -Dtgrid.suite.custom.includepackage="$tgrid.suite.custom.includepackage" -Dtgrid.suite.custome.excludepackage="$tgrid.suite.custome.excludepackage" -Dtgrid.suite.custom.jvmargs="$tgrid.suite.custom.jvmargs" -Djvm.size.args="$jvm.size.args" -Dmilestone="$milestone" -Dbuild.gs.version="$build.gs.version" -Dsvn.revision="$svn.revision" -Drelease.build="$release.build" -Dsvnant.repository.user="$svnant.repository.user" -Dsvnant.repository.passwd="$svnant.repository.passwd" -Dput.user="$put.user" -Dpublish.package.to.S3="$publish.package.to.S3" -Ds3.publish.folder="$s3.publish.folder" -Dpublish.jars.to.S3="$publish.jars.to.S3" -Dmaven.repo.local="$maven.repo.local" -Dbuild.timestamp="$build.timestamp" -Ds3.dev.and.packages.publish.folder="$s3.dev.and.packages.publish.folder"'
      git checkout $branch
      pushd core/tools
        #build runtimes and openspaces
        ##echo "ant -f quickbuild.xml ciCompilation $ant_params"
        ##ant -f quickbuild.xml ciCompilation $ant_params
        #run unit tests
        ##ant -f quickbuild.xml ciTests $ant_params
      popd
    done
else
    echo "### Everything up-to-date"
fi

git checkout master
git clean -df
git reset --hard origin/master  
git pull

echo "### Done"
