#!/bin/bash

echo "Automation script"

export JIRA_TICKETS="Ticket-1 Ticket-2"
export NOTES_FOR_RUN="Please go to Docgenerator directory and execute: java -jar DocGenerator.jar <parameters>"
export BUILD_DIR=`date '+%Y-%m-%d_%H-%M-%S'`

mkdir ${BUILD_DIR}

cd ${BUILD_DIR}
mkdir temp
cd temp
svn checkout http://subversion.alise.lv/CMTOOLS/Delivery_Documentation/trunk/DeliveryDocumentationGenerator --username ${svn_user} --password ${svn_password} >>/dev/null

cd DeliveryDocumentationGenerator
ant jar >ant_output
cat ant_output | grep "BUILD SUCCESSFUL"
if [ $? -ne 0 ]; then
	exit 1
fi

cp build/DocGenerator.jar ../../
cd ../../
rm -rf temp

for jira_tickets in `echo ${JIRA_TICKETS}`
do
	echo ${jira_tickets} >> Release_notes.txt
done

echo "${NOTES_FOR_RUN}" >> Installation_guide.txt

cd ..

zip -9 -r ${BUILD_DIR}.zip ${BUILD_DIR}

exit 0