import os

os.environ["DEFAULT_CONFIG_FILE_PATH"]="yoci/config.yml"

import json
import yoci.travis.functional_api

fail_file="cosmo_unit_tests_fail.log"

branch_name=os.environ["BRANCH_NAME"]
tests_repos_sha_list=os.environ["TESTS_REPO_SHA_LIST"]
print "tests_repos_sha_list="+tests_repos_sha_list
#defauly_config_file_path=os.environ["DEFAULT_CONFIG_FILE_PATH"]


#tests_repos_sha_list=os.environ["TESTS_REPO_SHA_LIST"]
#repos_list=['cloudify-dsl-parser']
#tests_repos_sha_list='{"cloudify-dsl-parser":"84fdbd52a2ac32e4b45765081db9b33942abb13d","cloudify-bash-plugin":"84fdbd52a2ac32e4b45765081db9b33942abb13d"}'
#tests_repos_sha_list='{"cloudify-rest-client":"af836286aa1bd04ea5ac339f982aa38bd7a92f17","cloudify-dsl-parser":"84fdbd52a2ac32e4b45765081db9b33942abb13d","cloudify-plugins-common":"90844994f0764d399bbae4aadfa99d6e80b76c59","cloudify-cli":"d225aa852b6e99af950c002971364e6509c66795","cloudify-manager":"9c06183aa10471c3c305086a15728f8ac80a2c96","cloudify-bash-plugin":"00dd5616ff30b0220c3127bb366fe22eaafe4594","cloudify-openstack-provider":"65584fc2b563d646309b074d8ce19948079a33bf","cloudify-chef-plugin":"7fb24409755e4b23e09666d1451934adc76b22ff","cloudify-diamond-plugin":"5d28de0b861b93b0ebd912de985d6530e97965eb","cloudify-fabric-plugin":"af6b8dedfb434bf8da2e560fcba7fa0d90c4e74a","cloudify-libcloud-plugin":"bc3a2c9bd1a6e8e2828d5dd8fae569139e3cb86e","cloudify-openstack-plugin":"81209d185235a24d036297b98774729b19f9392a","cloudify-puppet-plugin":"0ad555f5ad398dfb5d0e6b6b8b1ad8f4d9a7b00c","cloudify-python-plugin":"ea5a1182e409d978a381965203934fbcf67d20df","cloudify-script-plugin":"8bf2fa191aa1c757a8fa95e25afa758c238b6967"}'
d = json.loads(tests_repos_sha_list)

current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('..')
print("root dir: "+parent_dir)
fail_repo=""

#sudo pip install -e current_dir

#for repo in repos_list:
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
