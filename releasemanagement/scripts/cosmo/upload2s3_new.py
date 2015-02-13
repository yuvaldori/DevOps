import commands
import sys
import os
import shutil, errno
from fabric.api import * #NOQA
import glob
import params
from boto.s3.connection import S3Connection

FILES_LIST=""
PRODUCT_VERSION="3.1.0"
MILESTONE="patch1"
BUILD_NUM="b86"
PACKAGE_SOURCE_PATH="/cloudify_tmp"
#3.1.0-ga-b85
PRODUCT_VERSION_FULL=PRODUCT_VERSION+"-"+MILESTONE+"-"+BUILD_NUM
PACKAGE_DEST_BUILD_DIR=PRODUCT_VERSION+"/"+MILESTONE+"-RELEASE"
PACKAGE_DEST_BUILD_PATH="org/cloudify3/"+PACKAGE_DEST_BUILD_DIR


def rename_packages(file_before_rename,new_file_name):
    file = glob.glob(os.path.join('{0}'.format(PACKAGE_SOURCE_PATH), file_before_rename))
    file = ''.join(file)
    print "From rename_packages"+file
    os.rename(file,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,new_file_name))
    return ''.join(glob.glob('{0}/{1}'.format(PACKAGE_SOURCE_PATH,new_file_name)))

def get_file_name_from_path(file_path):
    return os.path.basename(file_path)

def upload_file_to_s3(source_file,dest_file):
    os.chdir( PACKAGE_SOURCE_PATH )
    full_key_name = os.path.join(PACKAGE_DEST_BUILD_PATH, source_file)
    key = bucket.new_key(full_key_name).set_contents_from_filename(dest_file, policy='public-read')
    print "uploaded file %s to S3" % fname

def main():
    
    filenames=[]
    BACKET_NAME="gigaspaces-repository-eu"
    bucket = conn.get_bucket(BACKET_NAME)
    conn = S3Connection(aws_access_key_id=params.AWS_KEY, aws_secret_access_key=params.AWS_SECRET)
    
    file=[x.strip() for x in FILES_LIST.split(",")]
    [i.split(":")[0] for i in file]
    
    upload_file_to_s3
    #ubuntu_agent=rename_packages('cloudify-trusty-agent_*.deb','cloudify-ubuntu-agent_'+PRODUCT_VERSION_FULL+'_amd64.deb')
    #file_name=get_file_name_from_path(ubuntu_agent)
    #filenames.append(file_name)

    docker
    print filenames
    upload_file_list_to_s3(filenames)

main()
