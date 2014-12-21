#!/bin/bash -x

source generic_functions.sh


echo "PACK_CLI=$PACK_CLI"
echo "PACK_CORE=$PACK_CORE"
echo "PACK_UI=$PACK_UI"
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
echo "run_unit_integration_tests=$run_unit_integration_tests"


#removing /cloudify folder
rm -rf /cloudify

if [ "$PACK_CORE" == "yes" ] || [ "$PACK_AGENT" == "yes" ] || [ "$PACK_CLI" == "yes" ] || [ "$yaml_spec_updater" == "yes" ]
	REPOS_LIST=$CORE_REPOS_LIST
fi
if [ "$PACK_CLI" == "yes" ] || [ "$yaml_spec_updater" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$CLI_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ] || [ "$yaml_spec_updater" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$UI_REPOS_LIST
fi
if [ "$PACK_CORE" == "yes" ] || [ "$PACK_UI" == "yes" ] || [ "$PACK_AGENT" == "yes" ] || [ "$yaml_spec_updater" == "yes" ]
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
		git pull
		exit_on_error
		git reset --hard origin/$BRANCHNAME
 		exit_on_error
 		#git clean -df .
 		#exit_on_error
 		
 		#if [ "$RELEASE_BUILD" == "false" ]
		#then#
			#echo "deleting $r nightly build branch if exist"
			#if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
	 		#then
	 			#git branch -D $VERSION_BRANCH_NAME
	 			#exit_on_error
	 		#fi
	 		#if [[ `git branch -r | grep origin/$VERSION_BRANCH_NAME` ]]
	 		#then
	 			##git branch -d -r origin/$VERSION_BRANCH_NAME
	 			##exit_on_error
	 			#git push origin --delete $VERSION_BRANCH_NAME
	 			#if [ $? != 0 ] ; then
			         	#git fetch origin --prune
			         	#exit_on_error
			      	#fi
	 		#fi
	 	#else
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
 				#exit_on_error
 			elif [[ `git branch -r | grep origin/$VERSION_BRANCH_NAME` ]]
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
	
	defaults_libcloud_config_yaml_file="cloudify-libcloud-provider/cloudify_libcloud/"$defaults_config_yaml_file_name
	config_libcloud_yaml_file="cloudify-libcloud-provider/cloudify_libcloud/"$config_yaml_file_name
	
	blueprints_openstack_yaml_file="cloudify-manager-blueprints/openstack/openstack.yaml"
	blueprints_simple_yaml_file="cloudify-manager-blueprints/simple/simple.yaml"
	blueprints_nova_net_yaml_file="cloudify-manager-blueprints/openstack-nova-net/openstack.yaml"
	
	system_tests_file=cloudify-system-tests/suites/system_tests.sh
	
	url_prefix="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE"
	ui_package_url=$url_prefix"/cloudify-ui_"$PRODUCT_VERSION_FULL"_amd64.deb"
	core_package_url=$url_prefix"/cloudify-core_"$PRODUCT_VERSION_FULL"_amd64.deb"
	#ubuntu_agent_url=$url_prefix"/cloudify-ubuntu-precise-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	ubuntu_agent_url=$url_prefix"/cloudify-ubuntu-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	centos_agent_url=$url_prefix"/cloudify-centos-final-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	windows_agent_url=$url_prefix"/cloudify-windows-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	components_package_url=$url_prefix"/cloudify-components_"$PRODUCT_VERSION_FULL"_amd64.deb"
	docker_url=$url_prefix"/cloudify-docker_"$PRODUCT_VERSION_FULL".tar"
	docker_data_url=$url_prefix"/cloudify-docker-data_"$PRODUCT_VERSION_FULL".tar"
	
	
	sed -i "s|components_package_url:.*|components_package_url: $(echo ${components_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file $blueprints_openstack_yaml_file $blueprints_simple_yaml_file $blueprints_nova_net_yaml_file
	sed -i "s|core_package_url:.*|core_package_url: $(echo ${core_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file $blueprints_openstack_yaml_file $blueprints_simple_yaml_file $blueprints_nova_net_yaml_file
	sed -i "s|ui_package_url:.*|ui_package_url: $(echo ${ui_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file $blueprints_openstack_yaml_file $blueprints_simple_yaml_file $blueprints_nova_net_yaml_file
	sed -i "s|ubuntu_agent_url:.*|ubuntu_agent_url: $(echo ${ubuntu_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file $blueprints_openstack_yaml_file $blueprints_simple_yaml_file $blueprints_nova_net_yaml_file
	sed -i "s|windows_agent_url:.*|windows_agent_url: $(echo ${windows_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file $blueprints_openstack_yaml_file $blueprints_simple_yaml_file $blueprints_nova_net_yaml_file
	sed -i "s|centos_agent_url:.*|centos_agent_url: $(echo ${centos_agent_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file $blueprints_openstack_yaml_file $blueprints_simple_yaml_file $blueprints_nova_net_yaml_file
	sed -i "s|docker_url:.*|docker_url: $(echo ${docker_url})|g" $blueprints_openstack_yaml_file $blueprints_simple_yaml_file $blueprints_nova_net_yaml_file
	sed -i "s|docker_data_url:.*|docker_data_url: $(echo ${docker_data_url})|g" $blueprints_openstack_yaml_file $blueprints_simple_yaml_file $blueprints_nova_net_yaml_file
	
	sed -i "s|BRANCH_NAME_CORE=\${BRANCH_NAME_CORE=.*|BRANCH_NAME_CORE=\${BRANCH_NAME_CORE='$core_tag_name'}|" $system_tests_file
	sed -i "s|BRANCH_NAME_PLUGINS=\${BRANCH_NAME_PLUGINS=.*|BRANCH_NAME_PLUGINS=\${BRANCH_NAME_PLUGINS='$plugins_tag_name'}|" $system_tests_file
	
fi

#python ./update-versions.py --repositories-dir . --cloudify-version $core_tag_name --plugins-version $plugins_tag_name --build-number $MAJOR_BUILD_NUM
#exit_on_error
echo "### version tool"
rm -rf version_tool_env
virtualenv version_tool_env
source version_tool_env/bin/activate
pushd repex
 pip install .
popd
pushd version-tool
 pip install .
popd
if [ "$MILESTONE" == "ga" ]
then
	version-control -p $plugins_tag_name_pre -c $core_tag_name_pre -b . -f version-tool/config/config.yaml -v
else	
	version-control -p $plugins_tag_name_pre -c $core_tag_name_pre -r $MILESTONE -b . -f version-tool/config/config.yaml -v
fi

if [ "$RELEASE_BUILD" == "true" ]
then
	if [ "$MILESTONE" == "ga" ]
	then
		version-control -p $plugins_tag_name_pre -c $core_tag_name_pre -b . -f version-tool/config/release-config.yaml -v
	else	
		version-control -p $plugins_tag_name_pre -c $core_tag_name_pre -r $MILESTONE -b . -f version-tool/config/release-config.yaml -v
	fi
fi
echo "### version tool - end"

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
		if [[ ! "$PACKAGER_REPOS_LIST" =~ "$r" ]]; then
			git add -u .
			# push versions to master/build-branch 
			#if [[ ! $(git status | grep 'nothing to commit') && ! $(git status | grep 'nothing added to commit') ]]
			#then
				git commit -m "Bump version to $VERSION_NAME"
				
				if [ "$RELEASE_BUILD" == "true" ]
		 		then
		 			git push origin $VERSION_BRANCH_NAME
		 			exit_on_error
		 		else
		 			git push origin $BRANCHNAME
		 			exit_on_error
		 		fi
		 	#fi
		 	
		 	#if [[ "$RELEASE_BUILD" == "true" && !`git branch -r | grep origin/$VERSION_BRANCH_NAME` ]]
		 	#then
		 	#	git push origin $VERSION_BRANCH_NAME
		 	#	exit_on_error
		 	#fi
		 	
		fi
	 	# create build branch in nightly - no need to create build branch on nightly travis step waits on tags
	 	#if [[ "$RELEASE_BUILD" == "false"  && "$run_unit_integration_tests" == "yes" ]]
	 	#then
	 		#git checkout -b $VERSION_BRANCH_NAME
	 		#exit_on_error
	 		#git push origin $VERSION_BRANCH_NAME
	 		#exit_on_error
	 	#fi
	 
 		sha=$(git rev-parse HEAD)
 		if [[ -z "$repo_names_sha" ]];then
 			repo_names_sha='[ "'$r'":"'$sha'"'	
 		else
 			repo_names_sha=$repo_names_sha',"'$r'":"'$sha'"'
 		fi
		
 	popd
	
done
repo_names_sha=$repo_names_sha' ]'
echo $repo_names_sha > repo_names_sha
  	
