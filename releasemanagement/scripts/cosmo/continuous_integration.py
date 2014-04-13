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

os.environ["TARZAN_BUILDS"]="/export/builds/cloudify3"
os.environ["PACK_COMPONENTS"]="yes" 
os.environ["PACK_CORE"]="yes" 
os.environ["PACK_UI"]="yes"
os.environ["BUILD_NUM"]="1-1"  
TARZAN_BUILDS=os.environ["TARZAN_BUILDS"] 
PACK_COMPONENTS=os.environ["PACK_COMPONENTS"]
PACK_CORE=os.environ["PACK_CORE"]
PACK_UI=os.environ["PACK_UI"]
BUILD_NUM=os.environ["BUILD_NUM"]
print TARZAN_BUILDS 
print PACK_COMPONENTS
print PACK_CORE
print PACK_UI
print BUILD_NUM

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


if PACK_CORE == "yes":
	print("*** packaging manager")
	# prepares virtualenv and copies relevant files to manager virtualenv
	get_manager()
	## install dsl-parser with dependencies into manager virtualenv (installing before manager-rest so manager-rest will not install it as dependency)
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(manager_conf['sources_path'],parent_dir+'/cloudify-dsl-parser'))
	## install manager with dependencies into manager virtualenv
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(manager_conf['sources_path'],parent_dir+'/cloudify-manager/rest-service'))
	## package manager virtualenv
	pkg_manager()

	print("*** packaging celery")
	get_celery()
	## install celery with dependencies into celery virtualenv
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(celery_conf['sources_path'],parent_dir+'/cloudify-rest-client'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(celery_conf['sources_path'],parent_dir+'/cloudify-plugins-common'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(celery_conf['sources_path'],parent_dir+'/cloudify-manager/plugins/plugin-installer'))
	do('{0}/bin/pip --default-timeout=45 install {1}'.format(celery_conf['sources_path'],parent_dir+'/cloudify-manager/plugins/agent-installer'))
	pkg_celery()
	manager_file = glob.glob(os.path.join('{0}'.format(manager_conf['package_path']), '{0}*.deb'.format(manager_conf['name'])))
	print manager_file
	celery_file = glob.glob(os.path.join('{0}'.format(celery_conf['package_path']), '{0}*.deb'.format(celery_conf['name'])))
	print celery_file
	if  manager_file and celery_file:
		pkg_cloudify_core()
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
	pkg_linux_agent()
	pkg_ubuntu_agent()

if PACK_UI == "yes":
	print("*** packaging ui")
	get_cloudify_ui()
	shutil.copyfile(parent_dir+"/cosmo-ui/dist/cosmo-ui-1.0.0.tgz", "{0}/cosmo-ui-1.0.0.tgz".format(cloudify_ui_conf['sources_path']))
	pkg_cloudify_ui()

	ui_file = glob.glob(os.path.join('{0}'.format(cloudify_ui_conf['package_path']), '{0}*.deb'.format(cloudify_ui_conf['name'])))
	print ui_file

	if  ui_file:
		pkg_cloudify_ui()
	else:
		print "Cannot pack cloudify-ui because missing deb files"
		sys.exit(1)







