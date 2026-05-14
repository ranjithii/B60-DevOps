#!/bin/bash

# I want to make sure that the scirpt has to validate whether the user running the script is root user or not, if not root user, script has to be exited
COMPONENT="rabbitmq"
source ./common.sh

echo -n "Configuring $COMPONENT repo :"
cp ${COMPONENT}.repo /etc/yum.repos.d/${COMPONENT}.repo &>> $LOG
stat $?

echo -n "Installing $COMPONENT server :"
dnf install rabbitmq-server -y &>> $LOG
stat $? 

echo -n "Starting $COMPONENT service: "
systemctl enable rabbitmq-server  &>> $LOG
systemctl start rabbitmq-server &>> $LOG
stat $?

rabbitmqctl list_users | grep roboshop  &>> $LOG
if [ $? -ne 0 ]; then 
    echo -n "Creatng $COMPONENT User"
    rabbitmqctl add_user ${APPUSER} roboshop123
    stat $?

    echo -n "Configuring Permissions: "
    rabbitmqctl set_user_tags ${APPUSER} administrator
    rabbitmqctl set_permissions -p / ${APPUSER} ".*" ".*" ".*"
    stat $?

else 
    echo -e "\e[33m Skipping \e[0m"
fi 

echo -e "\n \t ___ Configuration Management for $COMPONENT is completed! ___"
