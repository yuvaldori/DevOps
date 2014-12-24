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
import commands
import sys
import os
import shutil, errno
from fabric.api import * #NOQA
import packages
import glob
import params
from boto.s3.connection import S3Connection

#TARZAN_BUILDS="/export/builds/cloudify3"
#PACK_COMPONENTS="yes"
#PACK_CORE="yes"
#PACK_AGENT="yes"
#PACK_UI="yes"
#PACK_CLI="yes"
#BUILD_NUM="1-20"
#CONFIGURATION_NAME="NightlyBuild"
#PRODUCT_VERSION="3.0.0"
#PRODUCT_VERSION_FULL="3.0.0-m1-b1-20"
#CONFIGURATION_PATH_NAME="root/cosmo/master/CI/NightlyBuild"
#CONFIGURATION_PATH_NAME="root/cosmo/branch/CI/NightlyBuild"
#MILESTONE="rc"


TARZAN_BUILDS=os.environ["TARZAN_BUILDS"] 
PACK_COMPONENTS=os.environ["PACK_COMPONENTS"]
PACK_CORE=os.environ["PACK_CORE"]
PACK_AGENT=os.environ["PACK_AGENT"]
PACK_UI=os.environ["PACK_UI"]
PACK_CLI=os.environ["PACK_CLI"]
CREATE_DOCKER_IMAGES=os.environ["CREATE_DOCKER_IMAGES"]
CREATE_VAGRANT_BOX=os.environ["CREATE_VAGRANT_BOX"]
BUILD_NUM=os.environ["BUILD_NUM"]
CONFIGURATION_NAME=os.environ["CONFIGURATION_NAME"]
PRODUCT_VERSION=os.environ["PRODUCT_VERSION"]
PRODUCT_VERSION_FULL=os.environ["PRODUCT_VERSION_FULL"]
CONFIGURATION_PATH_NAME=os.environ["CONFIGURATION_PATH_NAME"]
MILESTONE=os.environ["MILESTONE"]
USER="tgrid"


print TARZAN_BUILDS 
print PACK_COMPONENTS
print PACK_CORE
print PACK_UI
print PACK_CLI
print BUILD_NUM
print CONFIGURATION_NAME
print PRODUCT_VERSION
print PRODUCT_VERSION_FULL
print CONFIGURATION_PATH_NAME
print MILESTONE


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
parent_dir=os.path.abspath('..')
print("root dir: "+parent_dir)


## copy cloudify3 package
if CONFIGURATION_NAME == "NightlyBuild":
	PACKAGE_DEST_DIR="nightly"
else:
	PACKAGE_DEST_DIR="continuous"

PACKAGE_DEST_BUILD_DIR=PRODUCT_VERSION+"/"+MILESTONE+"-RELEASE"
PACKAGE_DEST_PATH="org/cloudify3/"+PACKAGE_DEST_DIR
PACKAGE_DEST_BUILD_PATH="org/cloudify3/"+PACKAGE_DEST_BUILD_DIR

#commands.getoutput('sudo chown tgrid -R {0}'.format(PACKAGE_SOURCE_PATH))
cloudify_core_conf = packages.PACKAGES['cloudify-core']
PACKAGE_SOURCE_PATH='{0}'.format(cloudify_core_conf['package_path'])

tarzan_links_file='nightly-tarzan.links'
tarzan_links_file_path=TARZAN_BUILDS+'/'+PACKAGE_DEST_BUILD_DIR+'/'+tarzan_links_file
remove_file(tarzan_links_file_path)

aws_links_file='nightly-aws.links'
aws_links_file_path=TARZAN_BUILDS+'/'+PACKAGE_DEST_BUILD_DIR+'/'+aws_links_file
remove_file(aws_links_file_path)

local_tarzan_links_file_path=current_dir+'/'+tarzan_links_file
remove_file(local_tarzan_links_file_path)

local_aws_links_file_path=current_dir+'/'+aws_links_file
remove_file(local_aws_links_file_path)

links_file='nightly.links'
local_links_file_path=current_dir+'/'+links_file
remove_file(local_links_file_path)

local('sudo chown {0} -R {1}'.format(USER,PACKAGE_SOURCE_PATH),capture=False)

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
			print "uploading nightly packages to Tarzan"
			#get the url prefix
			url_prefix=""
			if fname.startswith('cloudify-components'):
				url_prefix="cloudify_components_package_url: "
			elif fname.startswith('cloudify-core'):
				url_prefix="cloudify_core_package_url: "
			elif fname.startswith('cloudify-ui'):
				url_prefix="cloudify_ui_package_url: "
			elif fname.startswith('cloudify-ubuntu-precise-agent'):
				url_prefix="cloudify_ubuntu_agent_url: "
			elif fname.startswith('cloudify-windows-agent'):
				url_prefix="cloudify_windows_agent_url: "
			elif fname.startswith('cloudify-windows-cli'):
				url_prefix="cloudify-windows-cli: "
			elif fname.startswith('cloudify-linux32-cli'):
				url_prefix="cloudify-linux32-cli: "
			elif fname.startswith('cloudify-linux64-cli'):
				url_prefix="cloudify-linux64-cli: "
			elif fname.startswith('cloudify-centos-final-agent'):
				url_prefix="cloudify-centos-agent: "
			elif fname.startswith('cloudify-docker'):
				url_prefix="cloudify-docker: "
			elif fname.startswith('cloudify-docker-data'):
				url_prefix="cloudify-docker-data: "

			print "uploading nightly packages to tarzan"
			if "master" in CONFIGURATION_PATH_NAME:
				mkdirp(TARZAN_BUILDS+"/"+PACKAGE_DEST_DIR)
				#Removing the version from packge name for nightly and continuous folders
				if fname.endswith(".exe"):
					name_without_version=fname.replace("_"+PRODUCT_VERSION_FULL,'')
				else:
					name_without_version=fname.replace(PRODUCT_VERSION_FULL+"_",'')
				shutil.copyfile(PACKAGE_SOURCE_PATH+"/"+fname,TARZAN_BUILDS+"/"+PACKAGE_DEST_DIR+"/"+name_without_version)
				f = open(TARZAN_BUILDS+'/'+PACKAGE_DEST_DIR+'/build.num', 'wb')
				f.write(BUILD_NUM)
				f.close()

			print "uploading release packages to tarzan"
			mkdirp(TARZAN_BUILDS+"/"+PACKAGE_DEST_BUILD_DIR)
			shutil.copyfile(PACKAGE_SOURCE_PATH+"/"+fname,TARZAN_BUILDS+"/"+PACKAGE_DEST_BUILD_DIR+"/"+fname)

			f1 = open(tarzan_links_file_path, 'a')
			f2 = open(aws_links_file_path, 'a')
			f3 = open(local_tarzan_links_file_path, 'a')
			f4 = open(local_aws_links_file_path, 'a')

			#"NIGHTLY_LINK"+str(x)+"
			f1.write(url_prefix+"http://192.168.10.13/builds/GigaSpacesBuilds/cloudify3/"+PACKAGE_DEST_BUILD_DIR+"/"+fname+"\n")
			f3.write(url_prefix+"http://192.168.10.13/builds/GigaSpacesBuilds/cloudify3/"+PACKAGE_DEST_BUILD_DIR+"/"+fname+"\n")
			f1.close()
			f3.close()

			print "uploaded file %s to Tarzan" % fname

			print "uploading nightly packages to S3"
			if "master" in CONFIGURATION_PATH_NAME:
				bucket = conn.get_bucket("gigaspaces-repository-eu")
				full_key_name = os.path.join(PACKAGE_DEST_PATH, name_without_version)
				key = bucket.new_key(full_key_name).set_contents_from_filename(fname, policy='public-read')
				f5 = open(local_links_file_path, 'a')
				f5.write(url_prefix+"http://gigaspaces-repository-eu.s3.amazonaws.com/"+PACKAGE_DEST_PATH+"/"+name_without_version+"\n")
				f5.close()

			print "uploading release packages to S3"
			bucket = conn.get_bucket("gigaspaces-repository-eu")
			full_key_name = os.path.join(PACKAGE_DEST_BUILD_PATH, fname)
			key = bucket.new_key(full_key_name).set_contents_from_filename(fname, policy='public-read')

			print "uploaded file %s to S3" % fname

			f2.write(url_prefix+"http://gigaspaces-repository-eu.s3.amazonaws.com/"+PACKAGE_DEST_BUILD_PATH+"/"+fname+"\n")
			f4.write(url_prefix+"http://gigaspaces-repository-eu.s3.amazonaws.com/"+PACKAGE_DEST_BUILD_PATH+"/"+fname+"\n")
			f2.close()

			f4.close()

def main():
	local('sudo chown {0} -R {1}'.format(USER,PACKAGE_SOURCE_PATH),capture=False)
	filenames=[]

	if CREATE_DOCKER_IMAGES == "yes":
		file_name=get_file_name_from_path(rename_packages('coudify-docker_*.tar','cloudify-docker_'+PRODUCT_VERSION_FULL+'.tar'))
		filenames.append(file_name)

		file_name=get_file_name_from_path(rename_packages('cloudify-docker-data_*.tar','cloudify-docker-data_'+PRODUCT_VERSION_FULL+'.tar'))
		filenames.append(file_name)

	if PACK_COMPONENTS == "yes":
		cloudify_components_conf = packages.PACKAGES['cloudify-components']
		cloudify_components_name = cloudify_components_conf['name']
		file_name=get_file_name_from_path(rename_packages(cloudify_components_name+'*.deb',cloudify_components_name+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
		filenames.append(file_name)

	if PACK_AGENT == "yes":
		centos_agent_final_conf = packages.PACKAGES['cloudify-centos-final-agent']
		centos_agent_final_name = centos_agent_final_conf['name']
		file_name=get_file_name_from_path(rename_packages(centos_agent_final_name+'*.deb',centos_agent_final_name+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
		filenames.append(file_name)

		ubuntu_agent_trusty_conf = packages.PACKAGES['cloudify-ubuntu-trusty-agent']
		ubuntu_agent_trusty_name = ubuntu_agent_trusty_conf['name']
		file_name=get_file_name_from_path(rename_packages(ubuntu_agent_trusty_name+'*.deb',ubuntu_agent_trusty_name+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
		filenames.append(file_name)

		ubuntu_agent_precise_conf = packages.PACKAGES['cloudify-ubuntu-precise-agent']
		ubuntu_agent_precise_name = ubuntu_agent_precise_conf['name']
		file_name=get_file_name_from_path(rename_packages(ubuntu_agent_precise_name+'*.deb',ubuntu_agent_precise_name+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
		filenames.append(file_name)
		
        	#file_name=get_file_name_from_path(rename_packages('cloudify-trusty-agent_*.deb','cloudify-ubuntu-agent_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
        	#filenames.append(file_name)

		windows_agent_conf = packages.PACKAGES['cloudify-windows-agent']
		windows_agent_name = windows_agent_conf['name']
		file_name=get_file_name_from_path(rename_packages(windows_agent_name+'*.deb',windows_agent_name+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
		filenames.append(file_name)

	if PACK_CLI == "yes":
		cli_linux32_name='cloudify-linux32-cli'
		file_name=get_file_name_from_path(rename_packages('cfy_*_i386.deb',cli_linux32_name+'_'+PRODUCT_VERSION_FULL+'_i386.deb'))
		filenames.append(file_name)

		cli_linux64_name='cloudify-linux64-cli'
		file_name=get_file_name_from_path(rename_packages('cfy_*_amd64.deb',cli_linux64_name+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
		filenames.append(file_name)

		cli_win_name='cloudify-windows-cli'
		file_name=get_file_name_from_path(rename_packages('CloudifyCLI*.exe',cli_win_name+'_'+PRODUCT_VERSION_FULL+'.exe'))
		filenames.append(file_name)

	if PACK_CORE == "yes":
		core_name = cloudify_core_conf['name']
		file_name=get_file_name_from_path(rename_packages(core_name+'*.deb',core_name+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
		filenames.append(file_name)

	if PACK_UI == "yes":
		ui_conf = packages.PACKAGES['cloudify-ui']
		ui_name = ui_conf['name']
		file_name=get_file_name_from_path(rename_packages(ui_name+'*.deb',ui_name+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'))
		filenames.append(file_name)

	if CREATE_VAGRANT_BOX == "yes":
		file_name=get_file_name_from_path(rename_packages('*.box','cloudify-virtualbox_'+PRODUCT_VERSION_FULL+'.box'))
		filenames.append(file_name)
		filenames.append('Vagrantfile')

	print filenames
	upload_file_list_to_s3(filenames)

main()

		
    	



