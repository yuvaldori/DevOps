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
		git checkout -b $VERSION_BRANCH_NAME tags/$TAG_NAME
 	popd
done
