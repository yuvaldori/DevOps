@echo on

set USER=%1
set PASSWORD=%2
set OLD_MILESTONE=%3
set NEW_MILESTONE=%4
set OLD_BUILD_NUMBER=%5
set NEW_BUILD_NUMBER=%6

cd ../../../
call mvn exec:java -Dexec.mainClass="EarlyAccessUpdate" -Dexec.args="%USER% %PASSWORD% %OLD_MILESTONE% %NEW_MILESTONE% %OLD_BUILD_NUMBER% %NEW_BUILD_NUMBER%"

