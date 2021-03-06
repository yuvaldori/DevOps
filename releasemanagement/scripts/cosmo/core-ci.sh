#!/bin/bash -x

source ../generic_functions.sh
source ../params.sh

branch_names=()
git checkout master

git fetch -v --dry-run > ../fetch.output 2>&1
IFS=$'\n'; list=($(cat ../fetch.output | grep -v 'up to date' | grep -v 'POST git-upload-pack' | grep -v 'From https' | grep -v 'error:')) ; echo "***list=${list[@]}"
unset IFS
git checkout master
git pull

[ -f ../send.email ] && rm -f ../send.email
[ -f ../branch.names ] && rm -f ../branch.names
ant_params='-Dnew.build.number=$new_build_number -Dbuild.type=$build_type -Dgs.product.version=$gs_product_version -Dtgrid.suite.target-jvm="$tgrid_suite_target_jvm" -DbuildDate-jvm="$buildDate" -Dcvs.root=$cvs_root -Dgs.internal.systems.not.available=$gs_internal_systems_not_available -Dbuild.qa.suite.type=$build_qa_suite_type -Dtgrid.suite.factory-class="$tgrid_suite_factory_class" -Dtgrid.suite.launcher-class="$tgrid_suite_launcher_class" -Dpermutation.file.path="$permutation_file_path" -Dbuild.qa.suite.version="$build_qa_suite_version" -Dtgrid.suite.custom.includepackage="$tgrid_suite_custom_includepackage" -Dtgrid.suite.custome.excludepackage="$tgrid_suite_custome_excludepackage" -Dtgrid.suite.custom.jvmargs="$tgrid_suite_custom_jvmargs" -Djvm.size.args="$jvm_size_args" -Dmilestone=$milestone -Dbuild.gs.version=$build_gs_version -Dsvn.revision=$svn_revision -Drelease.build=$release_build -Dsvnant.repository.user=$svnant_repository_user -Dsvnant.repository.passwd=$svnant_repository_passwd -Dput.user=$put_user -Dpublish.package.to.S3=$publish_package_to_S3 -Ds3.publish.folder=$s3_publish_folder -Dpublish.jars.to.S3=$publish_jars_to_S3 -Dmaven.repo.local=$maven_repo_local -Dbuild.timestamp="$build_timestamp" -Ds3.dev.and.packages.publish.folder=$s3_dev_and_packages_publish_folder'
echo "ant_params=$ant_params"

if [[ $list ]]
then
    for line in "${list[@]}"
    do
      echo "***line=$line"
      if [[ "$line" =~ "\[new branch\]" ]]
      then
        branch_names+=($(echo "$line" | awk '{ print $4 }'))
        echo "yes" > ../send.email
      else
        commit=$(echo "$line" | awk '{ print $1 }')
        echo "***commit=$commit"
        echo "***files=$(git show --name-only $commit)"
        if [[ $(git show --name-only $commit | grep 'core/\|openspaces/\|tests/\|tf/') ]]
        then
          branch_names+=($(echo "$line" | awk '{ print $2 }'))
          echo "yes" > ../send.email
        else
          echo "### Everything up-to-date"
        fi
      fi
    done
    IFS=$'\n'; echo "***branch_names=${branch_names[@]}"
    echo "${branch_names[@]}" > ../branch.names
    unset IFS
    for branch in "${branch_names[@]}"
    do
      echo "JAVA_HOME=$JAVA_HOME"
      export JAVA_HOME=$JAVA_HOME
      #ant_params="-Dnew.build.number=$new_build_number -Dbuild.type=$build_type -Dgs.product.version=$gs_product_version -Dtgrid.suite.target-jvm=$tgrid_suite_target_jvm -DbuildDate-jvm=$buildDate -Dcvs.root=$cvs_root -Dgs.internal.systems.not.available=$gs_internal_systems_not_available -Dbuild.qa.suite.type=$build_qa_suite_type -Dtgrid.suite.factory-class=$tgrid_suite_factory_class -Dtgrid.suite.launcher-class=$tgrid_suite_launcher_class -Dpermutation.file.path=$permutation_file_path -Dbuild.qa.suite.version=$build_qa_suite_version -Dtgrid.suite.custom.includepackage=$tgrid_suite_custom_includepackage -Dtgrid.suite.custome.excludepackage=$tgrid_suite_custome_excludepackage -Dtgrid.suite.custom.jvmargs=$tgrid_suite_custom_jvmargs -Djvm.size.args=$jvm_size_args -Dmilestone=$milestone -Dbuild.gs.version=$build_gs_version -Dsvn.revision=$svn_revision -Drelease.build=$release_build -Dsvnant.repository.user=$svnant_repository_user -Dsvnant.repository.passwd=$svnant_repository_passwd -Dput.user=$put_user -Dpublish.package.to.S3=$publish_package_to_S3 -Ds3.publish.folder=$s3_publish_folder -Dpublish.jars.to.S3=$publish_jars_to_S3 -Dmaven.repo.local=$maven_repo_local -Dbuild.timestamp=$build_timestamp -Ds3.dev.and.packages.publish.folder=$s3_dev_and_packages_publish_folder"
      git checkout $branch
      pushd core/tools
        #build runtimes and openspaces
        echo "### Starting ciCompilation on $branch"
        ant -f quickbuild.xml ciCompilation $ant_params
        echo "### ciCompilation on $branch Done"
        #run unit tests
        echo "### Starting ciTests on $branch"
        ant -f quickbuild.xml ciTests $ant_params
        echo "### ciTests on $branch Done"
      popd
    done
else
    echo "### Everything up-to-date"
fi

echo "### Clean environment"
git checkout master
git clean -df
git reset --hard origin/master  
#git pull

echo "### Done"
