#!/bin/bash -x

source generic_functions.sh
source credentials.sh

echo "PACK_CLI=$PACK_CLI"
echo "PACK_CORE=$PACK_CORE"
echo "PACK_UI=$PACK_UI"
echo "CREATE_VAGRANT_BOX=$CREATE_VAGRANT_BOX"
echo "CREATE_DOCKER_IMAGES=$CREATE_DOCKER_IMAGES"
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

if [ "$PACK_AGENT" == "yes" ] || [ "$PACK_CLI" == "yes" ] || [ "$yaml_spec_updater" == "yes" ] || [ "$CREATE_VAGRANT_BOX" == "yes" ] || [ "$CREATE_DOCKER_IMAGES" == "yes" ]
then
	REPOS_LIST=$CORE_REPOS_LIST
fi
if [ "$PACK_CLI" == "yes" ] || [ "$yaml_spec_updater" == "yes" ] || [ "$CREATE_VAGRANT_BOX" == "yes" ] || [ "$CREATE_DOCKER_IMAGES" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$CLI_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ] || [ "$yaml_spec_updater" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$UI_REPOS_LIST
fi
if [ "$PACK_UI" == "yes" ] || [ "$PACK_AGENT" == "yes" ] || [ "$yaml_spec_updater" == "yes" ] || [ "$CREATE_VAGRANT_BOX" == "yes" ] || [ "$CREATE_DOCKER_IMAGES" == "yes" ]
then
	REPOS_LIST=$REPOS_LIST" "$PACKAGER_REPOS_LIST
fi

echo "REPOS_LIST= $REPOS_LIST"


echo "### Repositories list: $REPOS_LIST"
for r in ${REPOS_LIST}
do
	echo "### Processing repository: $r"
	VERSION_BRANCH_NAME=$(get_version_name $r $core_tag_name $plugins_tag_name)"-build"
	echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
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
 		
 		
	 	if [ "$RELEASE_BUILD" == "true" ]
	 	then
 			#echo "Branch named $VERSION_BRANCH_NAME already exists, deleting it"
 			#git branch -D $VERSION_BRANCH_NAME
 			#exit_on_error
 			#git push origin --delete $VERSION_BRANCH_NAME
 			if [[ `git branch | grep $VERSION_BRANCH_NAME` ]]
 			then
 				#git checkout $VERSION_BRANCH_NAME
 				#exit_on_error
 				#git reset --hard origin/$VERSION_BRANCH_NAME
 				#exit_on_error
 				git branch -D $VERSION_BRANCH_NAME
 				exit_on_error
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


#if [[ "$PACK_CLI" == "yes" || "$CREATE_VAGRANT_BOX" == "yes" || "$CREATE_DOCKER_IMAGES" == "yes"  ||  "$PACK_AGENT" == "yes" ]]
#then
	blueprints_aws_ec2_yaml="cloudify-manager-blueprints/aws-ec2/aws-ec2-manager-blueprint.yaml"
	blueprints_cloudstack_yaml="cloudify-manager-blueprints/cloudstack/cloudstack-manager-blueprint.yaml"
	blueprints_nova_net_yaml="cloudify-manager-blueprints/openstack-nova-net/openstack-nova-net-manager-blueprint.yaml"
	blueprints_openstack_yaml="cloudify-manager-blueprints/openstack/openstack-manager-blueprint.yaml"
	blueprints_simple_yaml="cloudify-manager-blueprints/simple/simple-manager-blueprint.yaml"
	blueprints_softlayer_yaml="cloudify-manager-blueprints/softlayer/softlayer-manager-blueprint.yaml"
	blueprints_vsphere_yaml="cloudify-vsphere-plugin/manager_blueprint/vsphere-manager-blueprint.yaml"
	
	url_prefix="http://gigaspaces-repository-eu.s3.amazonaws.com/org/cloudify3/"$MAJOR_VERSION"."$MINOR_VERSION"."$SERVICEPACK_VERSION"/"$MILESTONE-"RELEASE"
	ui_package_url=$url_prefix"/cloudify-ui_"$PRODUCT_VERSION_FULL"_amd64.deb"
	ubuntu_agent_precise_url=$url_prefix"/cloudify-ubuntu-precise-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	ubuntu_agent_url=$url_prefix"/cloudify-ubuntu-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	ubuntu_agent_commercial_url=$url_prefix"/cloudify-ubuntu-commercial-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	centos_agent_url=$url_prefix"/cloudify-centos-final-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	windows_agent_url=$url_prefix"/cloudify-windows-agent_"$PRODUCT_VERSION_FULL"_amd64.deb"
	docker_url=$url_prefix"/cloudify-docker_"$PRODUCT_VERSION_FULL".tar"
	docker_commercial_url=$url_prefix"/cloudify-docker-commercial_"$PRODUCT_VERSION_FULL".tar"
	
	#sed -i "s|ui_package_url.*|ui_package_url: $(echo ${ui_package_url})|g" $defaults_config_yaml_file $config_yaml_file $defaults_libcloud_config_yaml_file $config_libcloud_yaml_file $blueprints_aws_ec2_yaml $blueprints_cloudstack_yaml $blueprints_nova_net_yaml $blueprints_openstack_yaml $blueprints_simple_yaml $blueprints_softlayer_yaml $blueprints_vsphere_yaml
	sed -i "s|ubuntu_agent_url.*|ubuntu_agent_url: $(echo ${ubuntu_agent_url})|g" $blueprints_aws_ec2_yaml $blueprints_cloudstack_yaml $blueprints_nova_net_yaml $blueprints_openstack_yaml $blueprints_simple_yaml $blueprints_softlayer_yaml $blueprints_vsphere_yaml
	sed -i "s|windows_agent_url.*|windows_agent_url: $(echo ${windows_agent_url})|g" $blueprints_aws_ec2_yaml $blueprints_cloudstack_yaml $blueprints_nova_net_yaml $blueprints_openstack_yaml $blueprints_simple_yaml $blueprints_softlayer_yaml $blueprints_vsphere_yaml
  	sed -i "s|centos_agent_url.*|centos_agent_url: $(echo ${centos_agent_url})|g" $blueprints_aws_ec2_yaml $blueprints_cloudstack_yaml $blueprints_nova_net_yaml $blueprints_openstack_yaml $blueprints_simple_yaml $blueprints_softlayer_yaml $blueprints_vsphere_yaml
	sed -i "s|docker_url.*|docker_url: $(echo ${docker_url})|g" $blueprints_aws_ec2_yaml $blueprints_cloudstack_yaml $blueprints_nova_net_yaml $blueprints_openstack_yaml $blueprints_simple_yaml $blueprints_softlayer_yaml $blueprints_vsphere_yaml
	
	#edit json file
	docker_file="cloudify-packager/docker/vars.py"
	sed -i "s|\"ui_package_url\":.*|\"ui_package_url\": \"$(echo ${ui_package_url})\",|g" $docker_file
	
	
	docker_ubuntu_merge_file="cloudify-packager/docker/ubuntu_agent/scripts/install_packman.sh"
	sed -i "s|.*cloudify-ubuntu-precise-agent.*|curl $(echo ${ubuntu_agent_precise_url}) --create-dirs -o /opt/tmp/manager/ubuntu_precise_agent.deb \&\& \\\|" $docker_ubuntu_merge_file
	
#fi

#python ./update-versions.py --repositories-dir . --cloudify-version $core_tag_name --plugins-version $plugins_tag_name --build-number $MAJOR_BUILD_NUM
#exit_on_error
echo "### version tool"
rm -rf version_tool_env
virtualenv version_tool_env
source version_tool_env/bin/activate

pip install repex==0.1.1

pushd version-tool
 pip install .
popd
if [ "$MILESTONE" == "ga" ]
then
	version-control -p $plugins_tag_name_pre -c $core_tag_name_pre -b . -f version-tool/config/config.yaml -v
	exit_on_error
else	
	version-control -p $plugins_tag_name_pre -c $core_tag_name_pre -r $MILESTONE -b . -f version-tool/config/config.yaml -v
	exit_on_error
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
deactivate
echo "### version tool - end"

echo "Creating metadata file"
metadata_file="metadata.json"
echo '{' > $metadata_file
	
echo "### Repositories list: $REPOS_LIST"
for r in ${REPOS_LIST}
do
	
	echo "### Processing repository: $r"
	VERSION_NAME=$(get_version_name $r $core_tag_name $plugins_tag_name)
	VERSION_BRANCH_NAME=$VERSION_NAME"-build"
	TAG_NAME=$VERSION_NAME
	echo "VERSION_BRANCH_NAME=$VERSION_BRANCH_NAME"
	if [ "$r" == "cosmo-grafana" ]
	then
		BRANCHNAME=$GRAFANA_BRANCH_NAME
	else
		BRANCHNAME=$BRANCH_NAME
	fi
	echo "BRANCHNAME=$BRANCHNAME"
	pushd $r
		#if [[ ! "$PACKAGER_REPOS_LIST" =~ "$r" ]]; then
		if [[ ! "yo-ci" == "$r" ]]; then
	        	#commit changes
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
		fi
		echo "TAG_NAME=$TAG_NAME"
		# recreate tag locally
		git tag -d $TAG_NAME
		#exit_on_error
		
        	git tag -f $TAG_NAME
        	exit_on_error
        	
        	# delete existing tag from remote - we must delete the old tag in order to make travis to run the tests on tags.
        	##git push --delete origin tag
        	git push origin :refs/tags/$TAG_NAME
        	exit_on_error
        	
        	# push tag to remote
		git push -f origin tag $TAG_NAME
		exit_on_error
	 	
 		sha="$(git rev-parse $TAG_NAME)"
 		if [[ -z "$repo_names_sha" ]];then
 			repo_names_sha='[ "'$r'":"'$sha'"'	
 		else
 			repo_names_sha=$repo_names_sha',"'$r'":"'$sha'"'
 		fi
 		
 		if [ "$r" == "cloudify-manager-blueprints" ]
 		then
 			popd
 			echo "Updating commercial blueprint"
 			sed -i "s|docker_url.*|docker_url: $(echo ${docker_commercial_url})|g" $blueprints_aws_ec2_yaml $blueprints_cloudstack_yaml $blueprints_nova_net_yaml $blueprints_openstack_yaml $blueprints_simple_yaml $blueprints_softlayer_yaml $blueprints_vsphere_yaml
 			sed -i "s|ubuntu_agent_url.*|ubuntu_agent_url: $(echo ${ubuntu_agent_commercial_url})|g" $blueprints_aws_ec2_yaml $blueprints_cloudstack_yaml $blueprints_nova_net_yaml $blueprints_openstack_yaml $blueprints_simple_yaml $blueprints_softlayer_yaml $blueprints_vsphere_yaml
 			pushd $r
 			temp_branch="commercial"
 			if [[ `git branch | grep $temp_branch` ]]
 			then
 				git branch -D $temp_branch
 				exit_on_error
 			elif [[ `git branch -r | grep origin/$temp_branch` ]]
 			then
 				git push origin --delete $temp_branch
 				exit_on_error
 			fi
 			
 			git checkout -b $temp_branch
 			exit_on_error
 			git add -u .
 			exit_on_error
 			git commit -m "Update commercial packages"
 			exit_on_error
 			git push origin $temp_branch
 			exit_on_error
 			
 			curl -u opencm:$GITHUB_PASSWORD -L https://github.com/cloudify-cosmo/cloudify-manager-blueprints/archive/$temp_branch.tar.gz > ../cloudify-manager-blueprints.tar.gz
 			
 			git checkout -
 			if [[ `git branch | grep $temp_branch` ]]
 			then
 				git branch -D $temp_branch
 				exit_on_error
 			elif [[ `git branch -r | grep origin/$temp_branch` ]]
 			then
 				git push origin --delete $temp_branch
 				exit_on_error
 			fi
                fi
 		
 		echo "Updating VERSION file (cloudify-cli/cloudify-ui)"
 		if [ "$r" == "cloudify-cli" ] || [ "$r" == "cloudify-ui" ]
		then
		        if [ "$r" == "cloudify-cli" ]
		        then
		                pushd cloudify_cli
		        fi
		        sed -i "s|\"date\":.*|\"date\": \"$(date +%Y-%m-%dT%H:%M:%S)\",|g" VERSION
		        sed -i "s|\"commit\":.*|\"commit\": \"$(echo ${sha})\",|g" VERSION
		        sed -i "s|\"build\":.*|\"build\": \"$(echo ${MAJOR_BUILD_NUM})\"|g" VERSION
		        if [ "$r" == "cloudify-cli" ]
		        then
		        	echo "Copy cli VERSION file to cloudify-packager folder"
		        	cp VERSION ../../cloudify-packager
		                popd
		        fi
		fi
		
		echo "Updating metadata file named $metadata_file"
		echo '    "'$r'": {' >> ../$metadata_file
		if [ "$RELEASE_BUILD" == "true" ]
 		then
 			echo '        "branch_name":"'$VERSION_BRANCH_NAME'",' >> ../$metadata_file
 		else
 			echo '        "branch_name":"'$BRANCHNAME'",' >> ../$metadata_file
 		fi
		echo '        "version":"'$TAG_NAME'",' >> ../$metadata_file
		echo '        "sha_id":"'$sha'"' >> ../$metadata_file
		echo '    },' >> ../$metadata_file
		

		
 	popd
	
done
repo_names_sha=$repo_names_sha' ]'
echo $repo_names_sha > repo_names_sha

echo '    "build":"'$MAJOR_BUILD_NUM'",' >> $metadata_file
echo '    "cloudify_version":"'$core_tag_name'",' >> $metadata_file
echo '    "patch_version":"",' >> $metadata_file
echo '    "creation_date":"'$(date +%Y-%m-%dT%H:%M:%S)'"' >> $metadata_file
echo '}' >> $metadata_file

echo "Check validation of $metadata_file file"
cat $metadata_file | sudo python -m simplejson.tool
exit_on_error

cp $metadata_file  cloudify-packager/docker/metadata
