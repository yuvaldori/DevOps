import os
import sys
import subprocess
from fabric.api import * #NOQA

os.environ["DEFAULT_CONFIG_FILE_PATH"]="yoci/config.yml"
pypi_branch_name=os.environ["pypi_branch_name"]

import yoci.travis.functional_api

def remove_pypi_release_branch():
        print "remove_pypi_release_branch"
        print os.getcwd()
        local('git checkout master',capture=False)
        local('git pull',capture=False)
        with settings(warn_only=True):
                result=local('git branch | grep {0}'.format(pypi_branch_name,capture=False))
                if result.return_code == 0:
                        local('git branch -D {0}'.format(pypi_branch_name),capture=False)
                result=local('git branch -r | grep origin/{0}'.format(pypi_branch_name,capture=False))
                if result.return_code == 0:
                        local('git push origin --delete {0}'.format(pypi_branch_name),capture=False)


core_branch_name=os.environ["RELEASE_CORE_BRANCH_NAME"]
print "core_branch_name="+core_branch_name
#core_branch_name='3.1rc1'
plugins_branch_name=os.environ["RELEASE_PLUGINS_BRANCH_NAME"]

parent_repo='cloudify-cosmo/'
fail_repos=""
#repo_list=['cloudify-cli','cloudify-plugins-common','cloudify-dsl-parser','cloudify-rest-client','cloudify-script-plugin','cloudify-diamond-plugin']
repo_list=['cloudify-diamond-plugin']

parent_dir=os.path.abspath('..')
print("root dir: "+parent_dir)
os.chdir(parent_dir)
print os.getcwd()

for repo in repo_list:
        print "### Processing repository: {0}".format(repo)
        #get tag name
        os.chdir('yo-ci')
        get_name=subprocess.Popen(['bash', '-c', '. generic_functions.sh ; get_version_name {0} {1} {2}'.format(repo, core_branch_name, plugins_branch_name)],stdout = subprocess.PIPE).communicate()[0]
	tag_name=get_name.rstrip()

	print "current_location="+os.getcwd()
	print "tag_name="+tag_name
        os.chdir(os.path.abspath('..'))
        
        os.chdir(repo)
        #Remove pypi_release_branch if exist
        remove_pypi_release_branch()
        local('git checkout master',capture=False)
        local('git pull',capture=False)
        local('git checkout -b {0} {1}'.format(pypi_branch_name,tag_name),capture=False)
        local('git push origin {0}'.format(pypi_branch_name),capture=False)
        os.chdir(os.path.abspath('..'))
        
for repo in repo_list:
        print "### Run tests for repository: {0}".format(repo)
        os.chdir(repo)
        sha=local('git rev-parse HEAD',capture=True)
        print sha
        
        try:
                jobs_state = yoci.travis.functional_api.get_jobs_status(sha,parent_repo+repo,branch_name=pypi_branch_name,timeout_min=180)
                for key,value in jobs_state.items():
                        ##print(key, ":", value)
                        if value=='passed':
                                print key + ' success'
                        else:
                                if repo not in fail_repos:
                                        fail_repos=fail_repos+','+repo
                                        print key + ' failure'
                                else:
                                        print key + ' failure'
        except RuntimeError:
                print 'Exception'
                fail_repos=fail_repos+','+repo
                remove_pypi_release_branch()

        remove_pypi_release_branch()
        os.chdir(os.path.abspath('..'))
