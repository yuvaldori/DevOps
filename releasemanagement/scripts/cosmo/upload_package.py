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

#os.environ["TARZAN_BUILDS"]="/export/builds/cloudify3"
#os.environ["PACK_COMPONENTS"]="no" 
#os.environ["PACK_CORE"]="yes" 
#os.environ["PACK_UI"]="yes"
#os.environ["PACK_CLI"]="yes"
#os.environ["BUILD_NUM"]="1-20"  
#os.environ["CONFIGURATION_NAME"]="NightlyBuild" 
#os.environ["PRODUCT_VERSION"]="3.0.0" 
#os.environ["PRODUCT_VERSION_FULL"]="3.0.0-m1-b1-20" 
#os.environ["CONFIGURATION_PATH_NAME"]="root/cosmo/trunk/CI/NightlyBuild"
#os.environ["CONFIGURATION_PATH_NAME"]="root/cosmo/branch/CI/NightlyBuild"

TARZAN_BUILDS=os.environ["TARZAN_BUILDS"] 
PACK_COMPONENTS=os.environ["PACK_COMPONENTS"]
PACK_CORE=os.environ["PACK_CORE"]
PACK_AGENT=os.environ["PACK_AGENT"]
PACK_UI=os.environ["PACK_UI"]
PACK_CLI=os.environ["PACK_CLI"]
BUILD_NUM=os.environ["BUILD_NUM"]
CONFIGURATION_NAME=os.environ["CONFIGURATION_NAME"]
PRODUCT_VERSION=os.environ["PRODUCT_VERSION"]
PRODUCT_VERSION_FULL=os.environ["PRODUCT_VERSION_FULL"]
CONFIGURATION_PATH_NAME=os.environ["CONFIGURATION_PATH_NAME"]
MILESTONE=os.environ["MILESTONE"]

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
local('sudo chown tgrid -R {0}'.format(PACKAGE_SOURCE_PATH),capture=False)


#This will be removed when the pkg_components will be ready
if PACK_COMPONENTS == "yes":
	cloudify_components_conf = packages.PACKAGES['cloudify-components']
	#print "copy 3rd parties deb from /packages folder"
	#components_new_name='cloudify-components_'+PRODUCT_VERSION_FULL+'_amd64.deb'
	#shutil.copyfile('/packages/cloudify-components_3.0.0_amd64.deb','{0}/{1}'.format(PACKAGE_SOURCE_PATH,components_new_name))
	components = glob.glob('{0}/{1}*.deb'.format(PACKAGE_SOURCE_PATH,cloudify_components_conf['name']))
	components = ''.join(components)
	print components
	components_new_name=cloudify_components_conf['name']+'_'+PRODUCT_VERSION_FULL+'_amd64.deb'
	os.rename(components,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,components_new_name))
	
	print "check that components_package deb files exist in /cloudify folder"
	components_package = glob.glob('{0}/{1}*.deb'.format(PACKAGE_SOURCE_PATH,cloudify_components_conf['name']))
	print components_package

if PACK_AGENT == "yes":
	centos_final_agent_conf = packages.PACKAGES['cloudify-centos-final-agent']
	centos_agent_final_name = centos_final_agent_conf['name']
	#centos_agent_name="cloudify-centos-agent"
	#ubuntu_agent_name="cloudify-ubuntu-agent"

	ubuntu_agent_trusty_conf = packages.PACKAGES['cloudify-ubuntu-trusty-agent']
	ubuntu_agent_precise_conf = packages.PACKAGES['cloudify-ubuntu-precise-agent']
	ubuntu_agent_trusty_name = ubuntu_agent_trusty_conf['name']
	ubuntu_agent_precise_name = ubuntu_agent_trusty_conf['name']
	
	
	#print "copy 3rd parties deb from /packages folder"
	#components_new_name='cloudify-components_'+PRODUCT_VERSION_FULL+'_amd64.deb'
	#shutil.copyfile('/packages/cloudify-components_3.0.0_amd64.deb','{0}/{1}'.format(PACKAGE_SOURCE_PATH,components_new_name))
	win_agent = glob.glob('{0}/cloudify-windows-agent_*_amd64.deb'.format(PACKAGE_SOURCE_PATH))
	print win_agent
	win_agent = ''.join(win_agent)
	print win_agent
	win_agent_new_name='cloudify-windows-agent_'+PRODUCT_VERSION_FULL+'_amd64.deb'
	os.rename(win_agent,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,win_agent_new_name))
	
	centos_agent = glob.glob('{0}/{1}_*_amd64.deb'.format(PACKAGE_SOURCE_PATH,centos_agent_final_name))
	print centos_agent
	centos_agent = ''.join(centos_agent)
	print centos_agent
	centos_agent_new_name='{0}_'.format(centos_agent_final_name)+PRODUCT_VERSION_FULL+'_amd64.deb'
	os.rename(centos_agent,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,centos_agent_new_name))
	
	ubuntu_agent = glob.glob('{0}/{1}_*_amd64.deb'.format(PACKAGE_SOURCE_PATH,ubuntu_agent_trusty_name))
	print ubuntu_agent
	ubuntu_agent = ''.join(ubuntu_agent)
	print ubuntu_agent
	ubuntu_agent_new_name='{0}_'.format(ubuntu_agent_trusty_name)+PRODUCT_VERSION_FULL+'_amd64.deb'
	os.rename(ubuntu_agent,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,ubuntu_agent_new_name))
	
	ubuntu_agent = glob.glob('{0}/{1}_*_amd64.deb'.format(PACKAGE_SOURCE_PATH,ubuntu_agent_precise_name))
	print ubuntu_agent
	ubuntu_agent = ''.join(ubuntu_agent)
	print ubuntu_agent
	ubuntu_agent_new_name='{0}_'.format(ubuntu_agent_precise_name)+PRODUCT_VERSION_FULL+'_amd64.deb'
	os.rename(ubuntu_agent,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,ubuntu_agent_new_name))
	
	ubuntu_trusty_package = glob.glob('{0}/{1}*.deb'.format(PACKAGE_SOURCE_PATH,ubuntu_agent_trusty_name))
	print ubuntu_trusty_package
	ubuntu_precise_package = glob.glob('{0}/{1}*.deb'.format(PACKAGE_SOURCE_PATH,ubuntu_agent_precise_name))
	print ubuntu_precise_package
	centos_agent_package = glob.glob('{0}/{1}*.deb'.format(PACKAGE_SOURCE_PATH,centos_agent_final_name))
	print centos_agent_package
	win_agent_package = glob.glob('{0}/cloudify-windows-agent_*_amd64.deb'.format(PACKAGE_SOURCE_PATH))
	print win_agent_package
	
if PACK_CLI == "yes":
	print "rename cli packages"
	cli_linux32_new_name='cloudify-linux32-cli_'+PRODUCT_VERSION_FULL+'_i386.deb'
	cli_linux64_new_name='cloudify-linux64-cli_'+PRODUCT_VERSION_FULL+'_amd64.deb'
	cli_win_new_name='cloudify-windows-cli_'+PRODUCT_VERSION_FULL+'.exe'
	
	cli_linux32 = glob.glob(os.path.join('{0}'.format(PACKAGE_SOURCE_PATH), 'cfy_*_i386.deb'))
	cli_linux32 = ''.join(cli_linux32)
	print cli_linux32
	os.rename(cli_linux32,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,cli_linux32_new_name))

	cli_linux64 = glob.glob(os.path.join('{0}'.format(PACKAGE_SOURCE_PATH), 'cfy_*_amd64.deb'))
	cli_linux64 = ''.join(cli_linux64)
	print cli_linux64
	os.rename(cli_linux64,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,cli_linux64_new_name))

	#orig name - CloudifyCLI-3.0.exe
	cli_win = glob.glob(os.path.join('{0}'.format(PACKAGE_SOURCE_PATH), 'CloudifyCLI*.exe'))
	cli_win = ''.join(cli_win)
	print cli_win
	os.rename(cli_win,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,cli_win_new_name))
	
	cli_linux32_package = glob.glob('{0}/cloudify-linux32-cli*_i386.deb'.format(PACKAGE_SOURCE_PATH))
	print cli_linux32_package
	cli_linux64_package = glob.glob('{0}/cloudify-linux64-cli*_amd64.deb'.format(PACKAGE_SOURCE_PATH))
	print cli_linux64_package
	cli_win_package = glob.glob('{0}/cloudify-windows-cli*.exe'.format(PACKAGE_SOURCE_PATH))
	print cli_win_package

if PACK_CORE == "yes":
	core_package = glob.glob('{0}/{1}*.deb'.format(PACKAGE_SOURCE_PATH,cloudify_core_conf['name']))
	print core_package

if PACK_UI == "yes":
	cloudify_ui_conf = packages.PACKAGES['cloudify-ui']
	ui_package = glob.glob('{0}/{1}*.deb'.format(PACKAGE_SOURCE_PATH,cloudify_ui_conf['name']))
	print ui_package


	
filenames=[]


if PACK_COMPONENTS == "yes":
	if components_package:
		a=components_package[0].split("/")		
		filenames.append(a[2]) 
	else:
		print "*** components package file is missing ***"
		exit(1)
if PACK_CORE == "yes":	
	if core_package:
		a=core_package[0].split("/")		
		filenames.append(a[2])
	else:
		print "*** core packages file is missing ***"
		exit(1)
if PACK_AGENT == "yes":	
	if ubuntu_trusty_package and ubuntu_precise_package and win_agent_package and centos_agent_package:
		a=ubuntu_trusty_package[0].split("/")		
		filenames.append(a[2])
		b=win_agent_package[0].split("/")		
		filenames.append(b[2])
		c=centos_agent_package[0].split("/")		
		filenames.append(c[2])
		d=ubuntu_precise_package[0].split("/")		
		filenames.append(c[2])
	else:
		print "*** agent packages files are missing ***"
		exit(1)
if PACK_CLI == "yes":	
	if cli_linux32_package and cli_linux64_package and cli_win_package:
		a=cli_linux32_package[0].split("/")		
		filenames.append(a[2])
		b=cli_linux64_package[0].split("/")		
		filenames.append(b[2])
		c=cli_win_package[0].split("/")		
		filenames.append(c[2])		
	else:
		print "*** cli packages files are missing ***"
		exit(1)
if PACK_UI == "yes":
	if ui_package:
		a=ui_package[0].split("/")		
		filenames.append(a[2])	
	else:
		print "*** ui package file is missing ***"
		exit(1)
print filenames

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

#x=1
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
	elif fname.startswith('cloudify-ubuntu-agent'):
		url_prefix="cloudify_ubuntu_agent_url: "
	elif fname.startswith('cloudify-windows-agent'):
		url_prefix="cloudify_windows_agent_url: "
	elif fname.startswith('cloudify-windows-cli'):
		url_prefix="cloudify-windows-cli: "
	elif fname.startswith('cloudify-linux32-cli'):
		url_prefix="cloudify-linux32-cli: "
	elif fname.startswith('cloudify-linux64-cli'):
		url_prefix="cloudify-linux64-cli: "
	elif fname.startswith('cloudify-centos-agent'):
		url_prefix="cloudify-centos-agent: "
		
	if "trunk" in CONFIGURATION_PATH_NAME:				
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
	if "trunk" in CONFIGURATION_PATH_NAME:
		bucket = conn.get_bucket("gigaspaces-repository-eu")
		full_key_name = os.path.join(PACKAGE_DEST_PATH, name_without_version)   	 	
		key = bucket.new_key(full_key_name).set_contents_from_filename(fname, policy='public-read') 		
   		f5 = open(local_links_file_path, 'a')
    		f5.write(url_prefix+"http://gigaspaces-repository-eu.s3.amazonaws.com/"+PACKAGE_DEST_PATH+"/"+name_without_version+"\n")
    		f5.close()
    		
	bucket = conn.get_bucket("gigaspaces-repository-eu")
	full_key_name = os.path.join(PACKAGE_DEST_BUILD_PATH, fname)   	 	
	key = bucket.new_key(full_key_name).set_contents_from_filename(fname, policy='public-read')

	print "uploaded file %s to S3" % fname

	f2.write(url_prefix+"http://gigaspaces-repository-eu.s3.amazonaws.com/"+PACKAGE_DEST_BUILD_PATH+"/"+fname+"\n")
	f4.write(url_prefix+"http://gigaspaces-repository-eu.s3.amazonaws.com/"+PACKAGE_DEST_BUILD_PATH+"/"+fname+"\n")	
	f2.close()
	
	f4.close()


	#x+=1

		
    	



