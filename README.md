
Scripts list under releasemanagement\scripts folder (build64A:/opt/git-repo)
1. releasemanagement\scripts\branch_tag
	1.1 create_cloudify_patch_2.6.X.sh
	1.2 create_git_branch_from_master.sh
	1.3 create_git_branch_from_tag.sh
	1.4 create_patch_9.5.X.sh
	1.5 create_patch_9.6.X.sh
	1.6 create_xap_branch_from_trunk.sh
	1.7 delete_git_branch.sh
	1.8 delete_git_tag.sh
	1.9 ipv6.sh
	
2. releasemanagement\scripts\clean_tarzan_builds_tgrid
	2.1 cleanup_tgrid.sh
	
3. releasemanagement\scripts\docs_handler
	3.1 setenv.sh
	3.2 xap_early_access.sh
	3.3 xap_release_8_X.sh
	3.4 xap_release_9_1_2_1.sh
	3.5 xap_release_9_1_X.sh
	3.6 xap_release_9_5_X.sh
	3.7 xap_release_9_6_X.sh
	
4. releasemanagement\scripts\java_versions
	4.1 configJava.sh
	
5. releasemanagement\scripts\s3
	5.1 s3clean.sh
	Description:
	clean s3 bucket - s3://gigaspaces-maven-repository-eu every 7 days
	clean_bucket - s3://gigaspaces-repository-eu every 45 days
	write deleted files to "/opt/scripts/s3/`date +\%Y\%m\%d`-s3clean.txt".
	
6. releasemanagement\scripts\update_xml_txt
	6.1 update_xmls_and_docs_links.sh
	Description:
	Update all xmls and txt\html files under svn folders: examples, gigaspaces, gigaspaces-dotnet, gigaspaces-poco/cpp, gs-webui mule, openspaces, openspaces-jetty, openspaces-scala, quality/frameworks/QA:
	Update XMLs with new version of XSDs and DTD.
	Update Documentation links with new wiki space.
	
7. releasemanagement\scripts\upload_release (build64A:/opt/bin)
	7.1 copy_milestone_packages_to_website.sh
	Description:
	upload following files to www.gigaspaces.com
	7.2 copy_release_packages_to_website.sh
	