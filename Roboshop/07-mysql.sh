#!/bin/bash

# I want to make sure that the scirpt has to validate whether the user running the script is root user or not, if not root user, script has to be exited
COMPONENT="mysql"
source ./common.sh

echo -n "Installing $COMPONENT server :"
dnf install mysql-server -y  &>> $LOG 
stat $? 

echo -n "Enabling $COMPONENT server"
systemctl enable mysqld   &>> $LOG 
stat $?

echo -n "Starting $COMPONENT server"
systemctl start mysqld   &>> $LOG 
stat $?

echo -n "Configuring the root password"
mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG 
stat $?

echo -e "\n \t ___ Configuration Management for $COMPONENT is completed! ___"
