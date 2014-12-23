import commands
import sys
import os
import shutil, errno
from fabric.api import * #NOQA
import glob
import params
from boto.s3.connection import S3Connection

PRODUCT_VERSION="3.1.0"
MILESTONE="patch1"
BUILD_NUM="b86"
PACKAGE_SOURCE_PATH="/cloudify_tmp"
USER="tgrid"
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

def upload_file_list_to_s3(filenames):
    os.chdir( PACKAGE_SOURCE_PATH )
    conn = S3Connection(aws_access_key_id=params.AWS_KEY, aws_secret_access_key=params.AWS_SECRET)
    for fname in filenames:
        bucket = conn.get_bucket("gigaspaces-repository-eu")
        full_key_name = os.path.join(PACKAGE_DEST_BUILD_PATH, fname)
        key = bucket.new_key(full_key_name).set_contents_from_filename(fname, policy='public-read')
        print "uploaded file %s to S3" % fname

def main():
    local('sudo chown {0} -R {1}'.format(USER,PACKAGE_SOURCE_PATH),capture=False)
    filenames=[]

    #ubuntu_agent=rename_packages('cloudify-trusty-agent_*.deb','cloudify-ubuntu-agent_'+PRODUCT_VERSION_FULL+'_amd64.deb')
    #file_name=get_file_name_from_path(ubuntu_agent)
    #filenames.append(file_name)

    docker=rename_packages('coudify-docker_*.tar','cloudify-docker_'+PRODUCT_VERSION_FULL+'.tar')
    file_name=get_file_name_from_path(docker)
    filenames.append(file_name)

    docker_data=rename_packages('cloudify-docker-data_*.tar','cloudify-docker-data_'+PRODUCT_VERSION_FULL+'.tar')
    file_name=get_file_name_from_path(docker_data)
    filenames.append(file_name)

    #virtalbox=rename_packages('*.box','cloudify-virtualbox_'+PRODUCT_VERSION_FULL+'.box')
    #file_name=get_file_name_from_path(virtalbox)
    #filenames.append(file_name)

    print filenames
    upload_file_list_to_s3(filenames)

main()
