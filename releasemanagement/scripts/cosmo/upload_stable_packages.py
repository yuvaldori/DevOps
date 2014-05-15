import commands
import sys
import os
import shutil, errno
from fabric.api import * #NOQA
import glob
import params
from boto.s3.connection import S3Connection

#os.environ["TARZAN_BUILDS"]="/export/builds/cloudify3"
#os.environ["PRODUCT_VERSION"]="3.0.0" 
#os.environ["CONFIGURATION_PATH_NAME"]="root/cosmo/trunk/CI/NightlyBuild"

TARZAN_BUILDS=os.environ["TARZAN_BUILDS"] 
PRODUCT_VERSION=os.environ["PRODUCT_VERSION"]
CONFIGURATION_PATH_NAME=os.environ["CONFIGURATION_PATH_NAME"]

print TARZAN_BUILDS 
print PRODUCT_VERSION
print CONFIGURATION_PATH_NAME

def mkdirp(directory):
    if not os.path.isdir(directory):
        os.makedirs(directory)

def copy_dir(src,dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('../..')
print("root dir: "+parent_dir)

## copy cloudify3 package
NIGHTLY_DIR="nightly"
TARZAN_SOURCE_DIR=TARZAN_BUILDS+"/"+NIGHTLY_DIR
f = open(TARZAN_SOURCE_DIR+'/build.num', 'rb')
BUILD_NUM=f.read()

NIGHTLY_BUILD_DIR=NIGHTLY_DIR+"_"+BUILD_NUM
STABLE_DIR="stable"
STABLE_BUILD_DIR=STABLE_DIR+"_"+BUILD_NUM

AWS_BASE_PATH="org/cloudify3/"
AWS_SOURCE_PATH=AWS_BASE_PATH+NIGHTLY_DIR
AWS_DEST_PATH=AWS_BASE_PATH+STABLE_DIR
AWS_DEST_BUILD_PATH=AWS_BASE_PATH+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR

TARZAN_SOURCE_BUILD_DIR=TARZAN_BUILDS+"/"+PRODUCT_VERSION+"/"+NIGHTLY_BUILD_DIR
TARZAN_STABLE_DIR=TARZAN_BUILDS+"/"+STABLE_DIR
TARZAN_STABLE_BUILD_DIR=TARZAN_BUILDS+"/"+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR

x=1
os.chdir( TARZAN_SOURCE_DIR )
conn = S3Connection(aws_access_key_id=params.AWS_KEY, aws_secret_access_key=params.AWS_SECRET)

if "trunk" in CONFIGURATION_PATH_NAME:
	for filename in glob.glob(os.path.join(TARZAN_SOURCE_DIR, '*.*')):
		mkdirp(TARZAN_STABLE_DIR)		
		shutil.copy(filename, TARZAN_STABLE_DIR)
		l=filename.split("/")
		fname=l[-1]
		bucket = conn.get_bucket("gigaspaces-repository-eu")		
		full_key_name = os.path.join(AWS_DEST_PATH, fname) 		 	 	
		key = bucket.new_key(full_key_name).set_contents_from_filename(filename, policy='public-read') 
		print "uploaded file %s" % filename
	   		
for filename in glob.glob(os.path.join(TARZAN_SOURCE_BUILD_DIR, '*.*')):
	mkdirp(TARZAN_STABLE_BUILD_DIR)
	shutil.copy(filename, TARZAN_STABLE_BUILD_DIR)
	f = open(TARZAN_BUILDS+'/'+TARZAN_STABLE_BUILD_DIR+'/build.links', 'a')
	f.write("NIGHTLY_LINK"+str(x)+"=http://192.168.10.13/builds/GigaSpacesBuilds/cloudify3/"+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR+"/"+fname+"\n")
	
	l=filename.split("/")
	fname=l[-1]
	bucket = conn.get_bucket("gigaspaces-repository-eu")
	full_key_name = os.path.join(AWS_DEST_BUILD_PATH, fname)   	 	
	key = bucket.new_key(full_key_name).set_contents_from_filename(filename, policy='public-read')
	f.write("STABLE_S3_LINK"+str(x)+"=http://repository.cloudifysource.org/org/"+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR+"/"+fname+"\n")
	f.close()
	
	print "uploaded file %s" % filename
    	



