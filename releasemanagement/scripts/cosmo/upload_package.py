#####################################################
# 	installations for packaging server	          #
#####################################################						
# apt-get update
# make
# python setup-tools python-dev fabric
# ruby2.1
# gem install fpm
# pip
# pip install virtualenv jinja2
# create log dirs:
# sudo mkdir -p /var/log/packager &&
#       sudo touch /var/log/packager/packager.log &&
#####################################################

import sys
import os
import shutil, errno
from fabric.api import * #NOQA
from get import *  # NOQA
from pkg import *  # NOQA
import config
from packager import *  # NOQA
import glob
import params
from boto.s3.connection import S3Connection



current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('../..')
print("root dir: "+parent_dir)

def copy_dir(src,dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

#export TARZAN_BUILDS=/export/builds/cloudify3

## copy cloudify3 package...
print "uploading cloudify3 package to s3 and tarzan/builds"
PACKAGE_SOURCE_PATH='{0}'.format(config.PACKAGES['cloudify3']['package_path'])
PACKAGE_DEST_PATH="latest"
if glob.glob('{0}/cloudify*.deb'.format(PACKAGE_SOURCE_PATH)):

	#print os.environ["TARZAN_BUILDS"]	
	copy_dir('{0}'.format(PACKAGE_SOURCE_PATH),os.environ["TARZAN_BUILDS"]+"/"+PACKAGE_DEST_PATH)
	print "uploaded file to {0}".format(os.environ["TARZAN_BUILDS"]+"/"+PACKAGE_DEST_PATH) 
	os.chdir( PACKAGE_SOURCE_PATH ) 
	filenames = ['cloudify3_3.0.0_amd64.deb', 'cloudify3-components_3.0.0_amd64.deb']
	conn = S3Connection(aws_access_key_id=params.AWS_KEY, aws_secret_access_key=params.AWS_SECRET)
	for fname in filenames:
    		bucket = conn.get_bucket("gigaspaces-cosmo-packages")    		
    		full_key_name = os.path.join(PACKAGE_DEST_PATH, fname)   	 	
		key = bucket.new_key(full_key_name).set_contents_from_filename(fname, policy='public-read') 		
   	 	print "uploaded file %s" % fname

else:
	print "Cannot upload cloudify3 package because cloudify3 deb file is missing"
	sys.exit(1)
	


