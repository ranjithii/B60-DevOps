#!/bin/bash

# I want to make sure that the scirpt has to validate whether the user running the script is root user or not, if not root user, script has to be exited
ID=$(id -u)
COMPONENT="catalogue"
APPUSER="roboshop"
LOG="/tmp/${COMPONENT}.log"

echo "Configuration Management for $COMPONENT in progress"

if [ $ID -ne 0 ]; then 
    echo -e "\e[35m Script has to executed as a root user or with sudo \e[0m"
    echo -e "Example Usage: \n\t \e[33m sudo bash $0  OR # bash $0 \e[0m"
    exit 1
fi

stat() {
    if [ $1 -eq 0 ]; then 
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[33m Failure \e[0m "
        exit 2
    fi 
}

echo -n "Disabling the default nodejs version :"
dnf module disable nodejs -y &>> $LOG
stat $? 

echo -n "Enabling the nodejs version 20 :"
dnf module enable nodejs:20 -y &>> $LOG
stat $? 

echo -n "Installing Nodejs :"
dnf install nodejs -y &>> $LOG
stat $?

id $APPUSER  &>> $LOG
if [ $? -ne 0 ]; then
    echo -n "Creating roboshop user account :"
    useradd $APPUSER 
    stat $?
else
    echo -n "SKIPPING"
fi 
stat $? 

echo -n "Performing cleanup of $COMPONENT :"
rm -rf /app/ || true 
stat $?

echo -n "Creating APP directory :"
mkdir /app
stat $? 

echo -n "Downloading the $COMPONENT app :"
curl -o /tmp/catalogue.zip https://stan-robotshop.s3.amazonaws.com/${COMPONENT}-v3.zip 
stat $?

echo -n "Configuring systemd for $COMPONENT :"
cp ${COMPONENT}.service /etc/systemd/system/${COMPONENT}.service

echo -n "Extracting the $COMPONENT app"
unzip -o /tmp/${COMPONENT}.zip -d /app/  &>> $LOG
stat $?

echo -n "Configuring Mongo shell repo :"
cp mongodb.repo /etc/yum.repos.d/mongo.repo

echo -n "Generating $COMPONENT Artifacts :"
cd /app/
npm install  &>> $LOG
stat  $? 

echo -n "Installing mongodb shell :"
dnf install mongodb-mongosh -y &>> $LOG
stat $?

echo -n "Injecting the schema :"
mongosh --host mongodb.krrinet.online </app/db/master-data.js &>> $LOG
stat $? 

echo -n "Starting $COMPONENT service :"
systemctl enable $COMPONENT &>> $LOG
systemctl start $COMPONENT &>> $LOG
stat $? 

echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"
