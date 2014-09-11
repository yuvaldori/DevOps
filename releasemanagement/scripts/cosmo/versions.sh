#!/bin/bash -x

source generic_functions.sh


echo "PACK_CLI=$PACK_CLI"
echo "PACK_CORE=$PACK_CORE"
echo "PACK_UI=$PACK_UI"
echo "MANAGER_SHA=$MANAGER_SHA"
echo "CLI_SHA=$CLI_SHA"
echo "UI_SHA=$UI_SHA"
echo "OS_PLUGIN_SHA=$OS_PLUGIN_SHA"
echo "BASH_PLUGIN_SHA=$BASH_PLUGIN_SHA"
echo "CHEF_PLUGIN_SHA=$CHEF_PLUGIN_SHA"
echo "PUPPET_PLUGIN_SHA=$PUPPET_PLUGIN_SHA"
echo "MAJOR_VERSION=$MAJOR_VERSION"
echo "MINOR_VERSION=$MINOR_VERSION"
echo "SERVICEPACK_VERSION=$SERVICEPACK_VERSION"
echo "MILESTONE=$MILESTONE"
echo "CORE_REPOS_LIST=$CORE_REPOS_LIST"
echo "UI_REPOS_LIST=$UI_REPOS_LIST"
echo "CLI_REPOS_LIST=$CLI_REPOS_LIST"
echo "PRODUCT_VERSION_FULL=$PRODUCT_VERSION_FULL"
echo "MAJOR_BUILD_NUM=$MAJOR_BUILD_NUM"
echo "BRANCH_NAME=$BRANCH_NAME"
echo "PLUGIN_MINOR_VER=$PLUGIN_MINOR_VER"
echo "PLUGIN_MAJOR_VER=$PLUGIN_MAJOR_VER"
echo "core_tag_name=$core_tag_name"
echo "plugins_tag_name=$plugins_tag_name"
echo "RELEASE_BUILD=$RELEASE_BUILD"
echo "PACKAGER_REPOS_LIST=$PACKAGER_REPOS_LIST"


if [ "$PACK_CORE" == "yes" ]
then
	REPOS_LIST=$CORE_REPOS_LIST
fi
if [ "$PACK_CLI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$CLI_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$UI_REPOS_LIST
fi
if [ "$PACK_CORE" == "yes" ] || [ "$PACK_UI" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$PACKAGER_REPOS_LIST
fi

echo "REPOS_LIST= $REPOS_LIST"


echo "### Repositories list: $REPOS_LIST"
for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"
	VERSION_BRANCH_NAME=$(get_version_name $r $core_tag_name $plugins_tag_name)"-build"
	echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
	if [ "$r" == "cosmo-grafana" ]
	then
		BRANCHNAME=$GRAFANA_BRANCH_NAME
	else
		BRANCHNAME=$BRANCH_NAME
	fi
	echo "BRANCHNAME=$BRANCHNAME"
	
	pushd $r
	
		git checkout $BRANCHNAME
		exit_on_error
		git reset --hard origin/$BRANCHNAME
 		exit_on_error
 		
		#if [[ `git branch -v -a | grep remotes/origin/$VERSION_BRANCH_NAME` ]]
		if [ "$RELEASE_BUILD" == "true" ]
 		then
 			#echo "Branch named $VERSION_BRANCH_NAME already exists, deleting it"
 			#git branch -D $VERSION_BRANCH_NAME
 			#exit_on_error
 			#git push origin --delete $VERSION_BRANCH_NAME
 			if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
 			then
 				git checkout $VERSION_BRANCH_NAME
 				exit_on_error
 				git reset --hard origin/$VERSION_BRANCH_NAME
 				exit_on_error
 			elif [[ `git branch -v -a | grep remotes/origin/$VERSION_BRANCH_NAME` ]]
 			then
 				git checkout -b $VERSION_BRANCH_NAME origin/$VERSION_BRANCH_NAME
 				exit_on_error
 				git reset --hard origin/$VERSION_BRANCH_NAME
 				exit_on_error
 			else
 				git checkout -b $VERSION_BRANCH_NAME
 				exit_on_error
 			fi
 		
 		fi		
 		
 	popd
	
done


if [[ "$PACK_CORE" == "yes" ||  "$PACK_CLI" == "yes" ]]
then
	defaults_config_yaml_file_name="cloudify-config.defaults.yaml"
	config_yaml_file_name="cloudify-config.yaml"
	
	defaults_config_yaml_file="cloudify-openstack-provider/cloudify_openstack/"$defaults_config_yaml_file_name
	config_yaml_file="cloudify-openstack-provider/cloudify_openstack/"$config_yaml_file_name
	
	defaults_cli_config_yaml_file="cloudify-cli/cloudify_simple_provider/"$defaults_config_yaml_file_name
	config_cli_yaml_file="cloudify-cli/cloudify_simple_provider/"$config_yaml_file_name
	
	defaults_libcloud_config_yaml_file="cloudify-libcloud-provider/cloudify_libcloud/"$defaults_config_yaml_file_name
	config_libcloud_yaml_file="cloudify-libcloud-provider/cloudify_libcloud/"$config_yaml_file_name
	
	
	ui_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE"-RELEASE/cloudify-ui_"$PRODUCT_VERSION_FULL"_amd64.deb"
	core_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-core_"$PRODUCT_VERSION_FULL"_amd64.deb"
	ubuntu_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-ubuntu-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	centos_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-centos-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	windows_agent_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-windows-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	components_package_url="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE/cloudify-components_"$PRODUCT_VERSION_FULL"_amd64.deb"


	sed -i "s|components_package_url:.*|components_package_url: $(echo ${components_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file
	sed -i "s|core_package_url:.*|core_package_url: $(echo ${core_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file
	sed -i "s|ui_package_url:.*|ui_package_url: $(echo ${ui_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file
	sed -i "s|ubuntu_agent_url:.*|ubuntu_agent_url: $(echo ${ubuntu_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file
	sed -i "s|windows_agent_url:.*|windows_agent_url: $(echo ${windows_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file
	sed -i "s|centos_agent_url:.*|centos_agent_url: $(echo ${centos_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_cli_config_yaml_file $config_cli_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file
	
	
fi

python ./update-versions.py --repositories-dir . --cloudify-version $core_tag_name --plugins-version $plugins_tag_name --build-number $MAJOR_BUILD_NUM
exit_on_error
	  	
echo "### Repositories list: $REPOS_LIST"
for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"
	VERSION_NAME=$(get_version_name $r $core_tag_name $plugins_tag_name)
	VERSION_BRANCH_NAME=$VERSION_NAME"-build"
	echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
	if [ "$r" == "cosmo-grafana" ]
	then
		BRANCHNAME=$GRAFANA_BRANCH_NAME
	else
		BRANCHNAME=$BRANCH_NAME
	fi
	echo "BRANCHNAME=$BRANCHNAME"
	pushd $r
		git add -u .
		git commit -m "Bump version to $VERSION_NAME"
		#if [[ `git branch -v -a | grep remotes/origin/$VERSION_BRANCH_NAME` ]]
		if [ "$RELEASE_BUILD" == "true" ]
 		then
 			git push origin $VERSION_BRANCH_NAME
 			exit_on_error
 		else
 			git push origin $BRANCHNAME
 			exit_on_error
 		fi
		
 	popd
	
done	  	
  	
