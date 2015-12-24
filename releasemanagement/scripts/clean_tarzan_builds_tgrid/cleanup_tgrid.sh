#!/bin/bash

echo "### Start cleaning `date +%d-%m-%y-%T`"

# Clean all folders that match "build_XXXX-YYY" pattern from builds directory and older than 4 days
find /export/builds/xap/xap[1-9]*/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/builds/xap/xap[1-9]*/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/builds/cloudify/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{3\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/builds/cloudify/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/builds/cloudify/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x

find /opt/builds-new/xap/xap[1-9]*/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /opt/builds-new/xap/xap[1-9]*/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /opt/builds-new/cloudify/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{3\}-" | awk '{print "rm -rf",$1}' | sh -x
find /opt/builds-new/cloudify/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /opt/builds-new/cloudify/[1-9]* -maxdepth 1 -mtime +3 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x

# Clean all folders that match "build_XXXX-YYY" pattern from TGRID environments and older than 7 days
find /export/tgrid/TestingGrid[1,C]*/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/TestingGrid[1,C]*/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x

# Clean all xml svn diff files that are older than 120 days
find /export/tgrid/TestingGrid[1,C]*/local-builds/summary-report/change -maxdepth 1 -mtime +120 -name *.xml |   awk '{print "rm -rf",$1}' | sh -x

# Clean all folders that match "build_XXXX-YYY" pattern from metric environment and older than 7 days
find /export/tgrid/metric/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/metric/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x

# Clean files from work/replication folder that are  older than 7 days
find /export/tgrid/metric/deploy/local-builds  -mtime +7  |  grep work | grep replication | grep redolog | awk '{print "rm -rf",$1}' | sh -x

# Clean all folders that match "build_XXX-YYY" or "build_XXXX-YYY" pattern from sgtest  environment and older than 14 days
# but, clean gigaspaces installation folder and package file every 2 days 
find /export/tgrid/sgtest/deploy/local-builds -maxdepth 1 -mtime +14 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest/deploy/local-builds -maxdepth 1 -mtime +14 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-xap/deploy/local-builds -maxdepth 1 -mtime +14 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-xap/deploy/local-builds -maxdepth 1 -mtime +14 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-cloudify/deploy/local-builds -maxdepth 1 -mtime +14 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-cloudify/deploy/local-builds -maxdepth 1 -mtime +14 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-cloudify/deploy/local-builds -maxdepth 1 -mtime +14 |  grep "build_[0-9]\{3\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-xap/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-xap/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-cloudify/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-cloudify/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest-cloudify/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{3\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest[1-9]*/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest[1-9]*/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x

# Clean all folders that match "build_XXX-YYY" or "build_XXXX-YYY" pattern from sgtest  environment and older than 7 days
# but, clean gigaspaces installation folder and package file every 2 days
find /export/tgrid/sgtest2.0-xap/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-xap/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-cloudify/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-cloudify/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-cloudify/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{3\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-xap/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-xap/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-cloudify/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-cloudify/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest2.0-cloudify/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{3\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest[1-9]*/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest[1-9]*/deploy/local-builds -maxdepth 2 -mtime +2 -name gigaspaces-*  |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x

# Clean all folders that match "build_XXX-YYY" or "build_XXXX-YYY" pattern from sgtest  environment and older than 7 days
# but, clean gigaspaces installation folder and package file every 2 days
find /export/tgrid/sgtest[1-9]*/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest[1-9]*/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/sgtest[1-9]*/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{3\}-" | awk '{print "rm -rf",$1}' | sh -x


# Clean all folders that match "build_XXXX-YYY" pattern from sgtest  environment and older than 7 days
find /export/tgrid/backwards/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{4\}-" | awk '{print "rm -rf",$1}' | sh -x
find /export/tgrid/backwards/deploy/local-builds -maxdepth 1 -mtime +7 |  grep "build_[0-9]\{5\}-" | awk '{print "rm -rf",$1}' | sh -x

echo "### End cleaning `date +%d-%m-%y-%T`"
