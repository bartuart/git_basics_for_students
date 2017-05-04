#!/bin/bash

echo "[BUILD_SCRIPT] Starting..."

echo "[BUILD_SCRIPT] Definition of variables..."
export JIRA_TICKETS="Ticket-1 Ticket-2"
export NOTES_FOR_RUN="Please go to Docgenerator directory and execute: java -jar DocGenerator.jar <parameters>"
export BUILD_DIR=`date '+%Y-%m-%d_%H-%M-%S'`

echo "[BUILD_SCRIPT] Creatin directory for build..."
mkdir ${BUILD_DIR}

echo "[BUILD_SCRIPT] Checking out source code from Subversion repository..."
cd ${BUILD_DIR}
#Creating temp directory will be used for checkout, this directory will be removed once JAR file is created
mkdir temp
cd temp
#SVN command line tool
svn checkout http://subversion.alise.lv/CMTOOLS/Delivery_Documentation/trunk/DeliveryDocumentationGenerator --username ${svn_user} --password ${svn_password} >>/dev/null
if [ $? -ne 0 ]; then
	echo "[BUILD_SCRIPT] Error during checking out source code from SVN repository!"
	echo "[BUILD_SCRIPT] The command was: svn checkout http://subversion.alise.lv/CMTOOLS/Delivery_Documentation/trunk/DeliveryDocumentationGenerator --username ${svn_user} --password ${svn_password}"
	exit 1
fi

echo "[BUILD_SCRIPT] Building JAR from source code using ANT script..."
cd DeliveryDocumentationGenerator
#move output to text file for further analyzing to find any errors
ant jar >ant_output
cat ant_output | grep "BUILD SUCCESSFUL"
#Successful ANT script should return "BUILD SUCCESSFUL" string anyway
if [ $? -ne 0 ]; then
	exit 1
fi

echo "[BUILD_SCRIPT] Copy created JAR file from temp folder to main build folder..."
cp build/DocGenerator.jar ../../
cd ../../
#remove temp directory with not used files and source code
rm -rf temp
echo "[BUILD_SCRIPT] Creating file with release notes..."
for jira_tickets in `echo ${JIRA_TICKETS}`
do
	echo ${jira_tickets} >> Release_notes.txt
done

echo "[BUILD_SCRIPT] Creating installation guide..."
echo "${NOTES_FOR_RUN}" >> Installation_guide.txt

#go back to current dir
cd ..

echo "[BUILD_SCRIPT] Creating zip file with JAR, release notes and installation guide..."
zip -9 -r ${BUILD_DIR}.zip ${BUILD_DIR}

echo "[BUILD_SCRIPT] Finished..."
exit 0