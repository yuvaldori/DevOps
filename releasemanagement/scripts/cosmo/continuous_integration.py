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
import glob
import shutil, errno
from fabric.api import * #NOQA
from get import *  # NOQA
from pkg import *  # NOQA
import packages
from packman import *  # NOQA

#os.environ["PACK_COMPONENTS"]="yes" 
#os.environ["PACK_CORE"]="yes" 
#os.environ["PACK_UI"]="yes"
#os.environ["BUILD_NUM"]="1-248" 
#os.environ["PRODUCT_VERSION_FULL"]="3.0.0-m1-b1-248" 

PACK_COMPONENTS=os.environ["PACK_COMPONENTS"]
PACK_CORE=os.environ["PACK_CORE"]
PACK_UI=os.environ["PACK_UI"]
BUILD_NUM=os.environ["BUILD_NUM"]
PRODUCT_VERSION=os.environ["PRODUCT_VERSION_FULL"]

print PACK_COMPONENTS
print PACK_CORE
print PACK_UI
print BUILD_NUM
print PRODUCT_VERSION

def copy_dir(src,dst):
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

current_dir=os.path.dirname(os.path.realpath(__file__))
print("current dir: "+current_dir)
parent_dir=os.path.abspath('../..')
print("root dir: "+parent_dir)


manager_conf = packages.PACKAGES['manager']
celery_conf = packages.PACKAGES['celery']
cloudify_ui_conf = packages.PACKAGES['cloudify-ui']
linux_conf = packages.PACKAGES['linux-agent']
cloudify_core_conf = packages.PACKAGES['cloudify-core']


PACKAGE_SOURCE_PATH='{0}'.format(cloudify_core_conf['package_path'])
if os.path.exists(PACKAGE_SOURCE_PATH):
	local('sudo chown tgrid -R {0}'.format(PACKAGE_SOURCE_PATH),capture=False)
	shutil.rmtree(PACKAGE_SOURCE_PATH)


if PACK_CORE == "yes":
	print("*** packaging manager")
	# prepares virtualenv and copies relevant files to manager virtualenv
	get_manager()
	## install dsl-parser with dependencies into manager virtualenv (installing before manager-rest so manager-rest will not install it as dependency)
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(manager_conf['sources_path'],parent_dir+'/cloudify-dsl-parser'))
	## install manager with dependencies into manager virtualenv
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(manager_conf['sources_path'],parent_dir+'/cloudify-manager/rest-service'))
	## package manager virtualenv
	packages.PACKAGES['manager']['version']=PRODUCT_VERSION
	pack(packages.PACKAGES['manager'])
	#pkg_manager()

	print("*** packaging celery")
	get_celery()
	## install celery with dependencies into celery virtualenv
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(celery_conf['sources_path'],parent_dir+'/cloudify-rest-client'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(celery_conf['sources_path'],parent_dir+'/cloudify-plugins-common'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(celery_conf['sources_path'],parent_dir+'/cloudify-manager/plugins/plugin-installer'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(celery_conf['sources_path'],parent_dir+'/cloudify-manager/plugins/agent-installer'))
	packages.PACKAGES['celery']['version']=PRODUCT_VERSION
	pack(packages.PACKAGES['celery'])
	#pkg_celery()

	print("*** packaging cloudify-core")
	manager_file = glob.glob(os.path.join('{0}'.format(manager_conf['package_path']), '{0}*.deb'.format(manager_conf['name'])))
	print manager_file
	celery_file = glob.glob(os.path.join('{0}'.format(celery_conf['package_path']), '{0}*.deb'.format(celery_conf['name'])))
	print celery_file
	if  manager_file and celery_file:
		packages.PACKAGES['cloudify-core']['version']=PRODUCT_VERSION
		pack(packages.PACKAGES['cloudify-core'])
		#pkg_cloudify_core()
	else:
		print "Cannot pack cloudify-core because missing deb files"
		sys.exit(1)
	
	print("*** packaging linux-agent")
	get_linux_agent()
	## install linux_agent with dependencies into celery virtualenv
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(linux_conf['sources_path'],parent_dir+'/cloudify-rest-client'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(linux_conf['sources_path'],parent_dir+'/cloudify-plugins-common'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(linux_conf['sources_path'],parent_dir+'/cloudify-manager/plugins/plugin-installer'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(linux_conf['sources_path'],parent_dir+'/cloudify-manager/plugins/agent-installer'))
	packages.PACKAGES['linux-agent']['version']=PRODUCT_VERSION
	pack(packages.PACKAGES['linux-agent'])
	packages.PACKAGES['ubuntu-agent']['version']=PRODUCT_VERSION
	pack(packages.PACKAGES['ubuntu-agent'])
	#pkg_linux_agent()
	#pkg_ubuntu_agent()

if PACK_UI == "yes":
	print("*** packaging ui")
	get_cloudify_ui()
	#shutil.copyfile(parent_dir+"/cosmo-ui/dist/cosmo-ui-1.0.0.tgz", "{0}/cosmo-ui-1.0.0.tgz".format(cloudify_ui_conf['sources_path']))
	#pkg_cloudify_ui()

	tar_ui_file = glob.glob(os.path.join(parent_dir+'/cosmo-ui/dist','cosmo-ui*.tgz'))
	print tar_ui_file
	shutil.copy(''.join(tar_ui_file),'{0}'.format(cloudify_ui_conf['sources_path']))
	
	#deb_ui_file = glob.glob(os.path.join('{0}'.format(cloudify_ui_conf['package_path']), '{0}*.deb'.format(cloudify_ui_conf['name'])))
	#print deb_ui_file

	if  tar_ui_file:
		packages.PACKAGES['cloudify-ui']['version']=PRODUCT_VERSION
		pack(packages.PACKAGES['cloudify-ui'])
		#pkg_cloudify_ui()
	else:
		print "Cannot pack cloudify-ui because missing tar files"
		sys.exit(1)







