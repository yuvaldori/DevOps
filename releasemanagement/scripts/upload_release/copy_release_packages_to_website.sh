#!/bin/bash

source params.sh

#create the lite packages
pushd ${BUILD_DIR} 
	mkdir xap-lite
	pushd xap-lite	
		cp -rp ../xap-premium/1.5/gigaspaces-xap-premium-* ../xap-premium/dotnet/GigaSpaces-XAP.NET-Premium-* .	
		rename 's/premium/lite/' *.zip
		rename 's/Premium/Lite/' *.msi
	popd
popd

ssh  -i ~/.ssh/website  tempfiles@www.gigaspaces.com "mkdir -p ~/download_files/${MAJOR}/${VERSION}/"

#for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi"  | grep -v license | grep -v testsuite | grep -v xap-premium.1.5`; do
#for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi"  | grep -v license | grep -v testsuite`; do

for file in `find ${BUILD_DIR} -name "*.zip" -o -name "*.tar.gz" -o -name "*.msi" -o -name "*.rpm" | grep -v license | grep -v testsuite`; do

  echo Uploading $file to ~/download_files/${MAJOR}/${VERSION}
  scp -i ~/.ssh/website $file tempfiles@www.gigaspaces.com:~/download_files/${MAJOR}/${VERSION}

done
