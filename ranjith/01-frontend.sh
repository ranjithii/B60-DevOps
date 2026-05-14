#!/bin/bash

echo "Configuration Management for frontend in progress"

# I want to make sure that the scirpt has to validate whether the user running the script is root user or not, if not root user, script has to be exited
ID=$(id -u)
COMPONENT="frontend"
LOG="/tmp/${COMPONENT}.log"

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

echo -n "Disabling the default nginx version: "
dnf module disable nginx -y &>> $LOG
stat $?

echo -n "Enabling Nginx 24 version: "
dnf module enable nginx:1.24 -y &>> $LOG
stat $?

echo -n "Installing Nginx:"
dnf install nginx -y &>> $LOG
stat $?

echo -n "Downloading the $COMPONENT component:"
curl -L -o /tmp/frontend.zip https://stan-robotshop.s3.amazonaws.com/$COMPONENT-v3.zip &>> $LOG
stat $?

echo -n "Performing cleanup:"
rm -rf /usr/share/nginx/html/
stat $?

echo -n "Extracting the $COMPONENT component: "
unzip -o /tmp/$COMPONENT.zip -d /usr/share/nginx/html/ &>> $LOG
stat $?

echo -n "Configuring $COMPONENT proxy file"
cp nginx.conf /etc/nginx/nginx.conf
stat $?

echo -n "Starting the $COMPONENT service: "
systemctl enable nginx &>> $LOG
systemctl restart nginx &>> $LOG
stat $?

echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"
