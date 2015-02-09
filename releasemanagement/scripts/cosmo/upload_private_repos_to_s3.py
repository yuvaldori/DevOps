import os
import sys
import params
import subprocess

from boto.s3.connection import S3Connection
#from boto.s3.key import Key
from fabric.api import * #NOQA

#set variables
core_branch_name = os.environ["RELEASE_CORE_BRANCH_NAME"]
plugins_branch_name = os.environ["RELEASE_PLUGINS_BRANCH_NAME"]
AWS_ACCESS_KEY_ID = params.AWS_KEY
AWS_SECRET_ACCESS_KEY = params.AWS_SECRET
scripts_path = 'devops/releasemanagement/scripts/allproj'

def download_private_plugin(repo):
    BUCKET_NAME=repo
    tar_file='{0}.tar.gz'.format(repo)
    os.remove(tar_file) if os.path.exists(tar_file) else None 
    #ver=os.path.basename(os.path.dirname(k))
    get_name=subprocess.Popen(['bash', '-c', '. generic_functions.sh ; get_version_name {0} {1} {2}'.format(repo, core_branch_name, plugins_branch_name)],stdout = subprocess.PIPE).communicate()[0]
    ver=get_name.rstrip()
    OBJECT='{0}/{1}'.format(ver,tar_file)
    local('curl -u opencm:{0} -L https://github.com/cloudify-cosmo/{1}/archive/{2}.tar.gz > {3}'.format(params.OPENCM_PWD,repo,ver,tar_file),capture=False)
    bucket = conn.get_bucket(BUCKET_NAME)
    #new_key = bucket.new_key(k.replace(os.path.basename(k),vsphere_tar_file)).set_contents_from_filename(vsphere_tar_file, policy=None)
    new_key = bucket.new_key(OBJECT).set_contents_from_filename(tar_file, policy=None)
    #print 'download_plugin key = {0}'.format(new_key)
    os.environ["bucket"]=BUCKET_NAME
    os.environ["object"]=OBJECT
    local('{0}/s3sign_url.sh'.format(scripts_path),capture=False)
    

if __name__ == '__main__':

    if not AWS_ACCESS_KEY_ID or not AWS_SECRET_ACCESS_KEY:
        print '- AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY environment variables are not set'
        sys.exit(1)
    conn = S3Connection(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
    
    os.environ["s3_access_key"]=params.AWS_KEY
    
    download_private_plugin('cloudify-vsphere-plugin')
    
  
