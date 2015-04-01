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
from packman.packman import *  # NOQA

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
parent_dir=os.path.abspath('..')
print("root dir: "+parent_dir)


#manager_conf = packages.PACKAGES['manager']
#celery_conf = packages.PACKAGES['celery']
#cloudify_ui_conf = packages.PACKAGES['cloudify-ui']
##cloudify_ubuntu_agent_conf = packages.PACKAGES['cloudify-ubuntu-agent']
##ubuntu_agent_conf = packages.PACKAGES['Ubuntu-agent']
#cloudify_core_conf = packages.PACKAGES['cloudify-core']


#PACKAGE_SOURCE_PATH='{0}'.format(cloudify_core_conf['package_path'])
PACKAGE_SOURCE_PATH="/cloudify"
'''if os.path.exists(PACKAGE_SOURCE_PATH):
	#local('sudo chown tgrid -R {0}'.format(PACKAGE_SOURCE_PATH),capture=False)
	shutil.rmtree(PACKAGE_SOURCE_PATH)'''


p = PythonHandler()

print("*** packaging winsows-agent")
do('pkm pack -c cloudify-windows-agent')

if PACK_UI == "yes":

	print("*** packaging ui")
	do('pkm get -c cloudify-ui')
	#shutil.copyfile(parent_dir+"/cosmo-ui/dist/cosmo-ui-1.0.0.tgz", "{0}/cosmo-ui-1.0.0.tgz".format(cloudify_ui_conf['sources_path']))
	#pkg_cloudify_ui()
        #cloudify_ui_source_path=cloudify_ui_conf['sources_path']
        #cloudify_ui_package_path=cloudify_ui_conf['package_path']
	#cloudify_ui_name=cloudify_ui_conf['name']
	cloudify_ui_source_path="/packages/cloudify-ui"
        cloudify_ui_package_path="/cloudify"
	cloudify_ui_name="cloudify-ui"
       
        
	tar_ui_file = glob.glob(os.path.join(parent_dir+'/cloudify-ui/dist','cosmo-ui*.tgz'))
	print tar_ui_file
	shutil.copy(''.join(tar_ui_file),'{0}'.format(cloudify_ui_source_path))
	tar_ui_grafana_file = glob.glob(os.path.join(parent_dir+'/cosmo-grafana/dist','grafana*.tgz'))
	print tar_ui_grafana_file
	shutil.copy(''.join(tar_ui_grafana_file),'{0}'.format(cloudify_ui_source_path))

	if  tar_ui_file:
		do('pkm pack -c cloudify-ui')
		cloudify_ui_file = glob.glob(os.path.join('{0}'.format(cloudify_ui_package_path), '{0}*.deb'.format(cloudify_ui_name)))
		cloudify_ui_file = ''.join(cloudify_ui_file)
		print cloudify_ui_file
		##rename cloudify-ui package
		os.rename(cloudify_ui_file,'{0}/{1}'.format(PACKAGE_SOURCE_PATH,'cloudify-ui_'+PRODUCT_VERSION+'_amd64.deb'))









local('sudo chown tgrid -R /opt',capture=False)
