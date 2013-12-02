LOCAL_TRUNK_DIR=/tmp/update_xml_docs
#LOCAL_TRUNK_DIR=/d/tmp/update_xml_docs
LOG_FILE=$LOCAL_TRUNK_DIR/update_xml_docs.log
MAJOR_OLD=9
MINOR_OLD=5
MAJOR_NEW=9
MINOR_NEW=7

echo "*** start ***" > $LOG_FILE

mkdir -p $LOCAL_TRUNK_DIR


#openspaces-jetty, openspaces-scala, mule - only xml gs-webui - only wiki space
dirs="examples gigaspaces gigaspaces-dotnet gigaspaces-poco/cpp gs-webui mule openspaces openspaces-jetty openspaces-scala quality/frameworks/QA"

for dir in $dirs
do
	echo "*** checkout $LOCAL_TRUNK_DIR/$dir ***" >> $LOG_FILE
	svn checkout svn://pc-lab14/SVN/xap/trunk/$dir $LOCAL_TRUNK_DIR/$dir
done



echo "*** Update XMLs with new version of XSDs and DTD ***" >> $LOG_FILE
find "${LOCAL_TRUNK_DIR}" -type f -not \( -name .svn -a -prune \) -name '*.xml' |
while read fname
do
	grep "dtd\/${MAJOR_OLD}_${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/dtd\/${MAJOR_OLD}_${MINOR_OLD}/dtd\/${MAJOR_NEW}_${MINOR_NEW}/g" "$fname"
	grep "schema\/${MAJOR_OLD}.${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/schema\/${MAJOR_OLD}.${MINOR_OLD}/schema\/${MAJOR_NEW}.${MINOR_NEW}/g" "$fname"
done

echo "*** Update Documentation links with new wiki space ***" >> $LOG_FILE
find "${LOCAL_TRUNK_DIR}" -type f -not \( -name .svn -a -prune \) -name '*.html' -o -name '*.txt' -o -name '*.properties' -o -name '*.bat' -o -name '*.java' |
while read fname
do	
	grep "display\/XAP${MAJOR_OLD}${MINOR_OLD}" "$fname" && echo "$fname" >> $LOG_FILE
	sed -i "s/display\/XAP${MAJOR_OLD}${MINOR_OLD}/display\/XAP${MAJOR_NEW}${MINOR_NEW}/g" "$fname"
done

echo "*** Display svn diff ***" >> $LOG_FILE
for dir in $dirs
do
	echo "*** svn diff $LOCAL_TRUNK_DIR/$dir ***" >> $LOG_FILE
	svn diff $LOCAL_TRUNK_DIR/$dir >> $LOG_FILE
done

#echo "*** Check-in changes to svn ***" >> $LOG_FILE
#for dir in $dirs
#do
#	svn ci --username '' --password '' -m 'Update files with new version of XSDs, DTD and wiki space' $dir  
#done






