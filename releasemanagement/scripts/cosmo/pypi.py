import os
import sys
#import shutil, errno
from fabric.api import * #NOQA

os.environ["DEFAULT_CONFIG_FILE_PATH"]="yoci/config.yml"

import yoci.travis.functional_api

def remove_pypi_release_branch():
        print "remove_pypi_release_branch"
        print os.getcwd()
        local('git checkout master',capture=False)
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
travis_repos=['cloudify-rest-client','cloudify-dsl-parser','cloudify-plugins-common','cloudify-cli','cloudify-manager','cloudify-fabric-plugin','cloudify-openstack-plugin','cloudify-script-plugin']
pypi_branch_name='pypi-release'
parent_repo='cloudify-cosmo/'
fail_repos=""
repo_list=['cloudify-cli','cloudify-plugins-common','cloudify-dsl-parser','cloudify-rest-client']
parent_dir=os.path.abspath('..')
print("root dir: "+parent_dir)
os.chdir(parent_dir)
print os.getcwd()

for repo in repo_list:
        print "### Processing repository: {0}".format(repo)
        os.chdir(repo)
        remove_pypi_release_branch()
        local('git checkout -b {0} {1}'.format(pypi_branch_name,core_branch_name),capture=False)
        local('git push origin {0}'.format(pypi_branch_name),capture=False)
        os.chdir(os.path.abspath('..'))
        
for repo in repo_list:
        print "### Run tests for repository: {0}".format(repo)
        os.chdir(repo)
        sha=local('git rev-parse HEAD',capture=False)
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
