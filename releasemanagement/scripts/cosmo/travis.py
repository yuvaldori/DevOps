import os
import json
import subprocess

os.environ["DEFAULT_CONFIG_FILE_PATH"]="yoci/config.yml"

import yoci.travis.functional_api

fail_repos=""
utests_fail_file="unit_tests_failure.log"
itests_fail_file="i_tests_failure.log"
if os.path.exists(utests_fail_file):
    os.remove(utests_fail_file)
if os.path.exists(itests_fail_file):
    os.remove(itests_fail_file)

tests_repos_sha_list=os.environ["TESTS_REPO_SHA_LIST"]
print "tests_repos_sha_list="+tests_repos_sha_list

branch_name=os.environ["BRANCH_NAME"]
release_build=os.environ["RELEASE_BUILD"]
core_branch_name=os.environ["RELEASE_CORE_BRANCH_NAME"]
plugins_branch_name=os.environ["RELEASE_PLUGINS_BRANCH_NAME"]


d = json.loads(tests_repos_sha_list)

for repo,sha in d.items():
	print repo
	print sha
	if release_build == "true":
		get_name=subprocess.Popen(['bash', '-c', '. generic_functions.sh ; get_version_name {0} {1} {2}'.format(repo, a, b)],stdout = subprocess.PIPE).communicate()[0]
		branch_name=get_name.rstrip()+"_build"
	print "branch_name="+branch_name
	
	if repo == 'cosmo-ui':
		parent_repo='CloudifySource/'
	else:
		parent_repo='cloudify-cosmo/'
	try:

		jobs_state = yoci.travis.functional_api.get_jobs_status(sha,
		parent_repo+repo,
		branch_name=branch_name,
		timeout_min=1)
		for key,value in jobs_state.items():
			#print(key, ":", value)
			if value=='passed':
				print key + ' success'
			else:
				print key + ' failure'
				if repo == "cloudify-manager" and "run-integration-tests" in key:
					print 'integration tests failed'
					f1 = open(itests_fail_file, 'w')
					f1.write("failed")
					f1.close()
				elif repo not in fail_repos:
					fail_repos=fail_repos+','+repo
				
		
	except RuntimeError:
		print 'Exception'
		fail_repos=fail_repos+','+repo		

if fail_repos:
	print 'fail_repos='+fail_repos
	f1 = open(utests_fail_file, 'w')
	f1.write(fail_repos)
	f1.close()
