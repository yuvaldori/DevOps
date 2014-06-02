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
#os.environ["CONFIGURATION_PATH_NAME"]="root/cosmo/branch/CI/NightlyBuild"

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

def remove_file(filename):
	if os.path.isfile(filename):	
		os.remove(filename)

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
STABLE_DIR="stable-nightly"
STABLE_BUILD_DIR=STABLE_DIR+"_"+BUILD_NUM

AWS_BASE_PATH="org/cloudify3/"
AWS_SOURCE_PATH=AWS_BASE_PATH+NIGHTLY_DIR
AWS_DEST_PATH=AWS_BASE_PATH+STABLE_DIR
AWS_DEST_BUILD_PATH=AWS_BASE_PATH+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR

TARZAN_SOURCE_BUILD_DIR=TARZAN_BUILDS+"/"+PRODUCT_VERSION+"/"+NIGHTLY_BUILD_DIR
TARZAN_STABLE_DIR=TARZAN_BUILDS+"/"+STABLE_DIR
TARZAN_STABLE_BUILD_DIR=TARZAN_BUILDS+"/"+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR


tarzan_links_file='stable-tarzan.links'
tarzan_links_file_path=TARZAN_STABLE_BUILD_DIR+'/'+tarzan_links_file
remove_file(tarzan_links_file_path)

aws_links_file='stable-aws.links'
aws_links_file_path=TARZAN_STABLE_BUILD_DIR+'/'+aws_links_file
remove_file(aws_links_file_path)

local_tarzan_links_file_path=current_dir+'/'+tarzan_links_file
remove_file(local_tarzan_links_file_path)

local_aws_links_file_path=current_dir+'/'+aws_links_file
remove_file(local_aws_links_file_path)


#x=1
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
	if not os.path.basename(filename).endswith('.links'):
		mkdirp(TARZAN_STABLE_BUILD_DIR)
		shutil.copy(filename, TARZAN_STABLE_BUILD_DIR)
		l=filename.split("/")
		fname=l[-1]

		f1 = open(tarzan_links_file_path, 'a')
		f2 = open(aws_links_file_path, 'a')
		f3 = open(local_tarzan_links_file_path, 'a')
		f4 = open(local_aws_links_file_path, 'a')

		#NIGHTLY_LINK"+str(x)
		f1.write("http://192.168.10.13/builds/GigaSpacesBuilds/cloudify3/"+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR+"/"+fname+"\n")
		f3.write("http://192.168.10.13/builds/GigaSpacesBuilds/cloudify3/"+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR+"/"+fname+"\n")
		f1.close()
		f3.close()

		print "uploaded file %s to Tarzan" % filename
		
		bucket = conn.get_bucket("gigaspaces-repository-eu")
		full_key_name = os.path.join(AWS_DEST_BUILD_PATH, fname)   	 	
		key = bucket.new_key(full_key_name).set_contents_from_filename(filename, policy='public-read')
		f2.write("http://repository.cloudifysource.org/org/"+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR+"/"+fname+"\n")
		f4.write("http://repository.cloudifysource.org/org/"+PRODUCT_VERSION+"/"+STABLE_BUILD_DIR+"/"+fname+"\n")
		f2.close()
		f4.close()

		print "uploaded file %s to S3" % filename
    	



