#!/bin/bash
source generic_functions.sh
branch_names=()
git fetch -v --dry-run >fetch.output 2>&1
IFS=$'\n'; list=($(cat fetch.output | grep -v 'up to date' | grep -v 'From https'))
for line in "${list[@]}"
do
echo $line
if [[ $line =~ '[new branch]' ]]
then
#echo "[new branch]"
#echo $line | awk '{ print $4 }'
branch_names+=($(echo $line | awk '{ print $4 }'))
else
#echo "stam"
#echo $line | awk '{ print $2 }'
branch_names+=($(echo $line | awk '{ print $2 }'))
fi
done
for branch in "${branch_names[@]}"
do
git checkout $branch
retry "bower install -f"
retry "bower update -f"
run_command "grunt test"
done
