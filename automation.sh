#!/bin/bash

echo "Automation script"

export JIRA_TICKETS="Ticket-1 Ticket-2"

export NOTES_FOR_RUN="Please go to Docgenerator directory and execute: java -jar DocGenerator.jar <parameters>"

export BUILD_DIR=`date '+%Y-%m-%d_%H-%M-%S'`

mkdir ${BUILD_DIR}

cd ${BUILD_DIR}
mkdir temp
cd temp
svn checkout http://subversion.alise.lv/CMTOOLS/Delivery_Documentation/trunk/DeliveryDocumentationGenerator --username ${svn_user} --password ${svn_password}

cd DeliveryDocumentationGenerator
ant jar

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
