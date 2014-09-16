import os

os.environ["DEFAULT_CONFIG_FILE_PATH"]="yoci/config.yml"

import json
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



d = json.loads(tests_repos_sha_list)

for repo,sha in d.items():
	print repo
	print sha
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
			print(key, ":", value)
			if value=='passed':
				print key + ' passed'
			else:
				print key + ' failed'
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
