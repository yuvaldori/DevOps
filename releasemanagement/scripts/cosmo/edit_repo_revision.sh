#!/bin/bash

#DSL_SHA=d2bedb39b62bddc3888c09e21163ab987f3d4883
#REST_CLIENT_SHA=b84591d8fb024f9bbf4679f361d15ec18fc1cae1
#CLI_SHA=1fee425e6a2f21a231f023fae4d7885ad07a0e4e
#OS_PROVIDER_SHA=2fa30b0b6b9c2e20068ed3d68e160390f309fcee

echo "DSL_SHA=$DSL_SHA"
echo "REST_CLIENT_SHA=$REST_CLIENT_SHA"
echo "CLI_SHA=$CLI_SHA"
echo "OS_PROVIDER_SHA=$OS_PROVIDER_SHA"

#edit the revision number in linux/provision.sh
fileName="linux/provision.sh"
win_fileName="windows/provision.bat"
sed -i 's/.*DSL_SHA=.*/DSL_SHA=${DSL_SHA}/g' $fileName $win_fileName
sed -i 's/.*REST_CLIENT_SHA=.*/REST_CLIENT_SHA=${REST_CLIENT_SHA}/g' $fileName $win_fileName
sed -i 's/.*CLI_SHA=.*/CLI_SHA=${CLI_SHA}/g' $fileName $win_fileName
sed -i 's/.*OS_PROVIDER_SHA=.*/OS_PROVIDER_SHA=${OS_PROVIDER_SHA}/g' $fileName $win_fileName
