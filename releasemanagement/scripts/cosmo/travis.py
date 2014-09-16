import os

os.environ["DEFAULT_CONFIG_FILE_PATH"]="yoci/config.yml"

import json
import yoci.travis.functional_api




fail_file="cosmo_unit_tests_fail.log"
branch_name=os.environ["BRANCH_NAME"]
tests_repos_sha_list=os.environ["TESTS_REPO_SHA_LIST"]
print "tests_repos_sha_list="+tests_repos_sha_list


d = json.loads(tests_repos_sha_list)

current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('..')
print("root dir: "+parent_dir)
fail_repo=""

#sudo pip install -e current_dir


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
			#print(key, ":", value)
			if value=='passed':
				print key + ' passed'
			else:
				print key + ' failed'
				fail_repo=fail_repo+','+repo						
		
	except RuntimeError:
		print 'Exception'
		fail_repo=fail_repo+','+repo		

if fail_repo:
	print 'fail_repo='+fail_repo
	f1 = open(fail_file, 'w')
	f1.write(fail_repo)
	f1.close()
