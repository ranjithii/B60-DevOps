#!/bin/bash



# I want to make sure that the scirpt has to validate whether the user running the script is root user or not, if not root user, script has to be exited
ID=$(id -u)
COMPONENT="mongodb"
LOG="/tmp/${COMPONENT}.log"

if [ $ID -ne 0 ]; then 
    echo -e "\e[35m Script has to executed as a root user or with sudo \e[0m"
    echo -e "Example Usage: \n\t \e[33m sudo bash $0  OR # bash $0 \e[0m"
    exit 1
fi

echo "Configuration Management for $COMPONENT in progress"

stat() {
    if [ $1 -eq 0 ]; then 
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[33m Failure \e[0m "
        exit 2
    fi 
}

echo -n "Configuring the repo:"
cp mongo.repo /etc/yum.repos.d/mongo.repo
stat $? 

echo -n "Installing $COMPONENT:"
dnf install mongodb-org -y  &>> $LOG 
stat $? 

echo -n "Updating the $COMPONENT visibility:"
sed -ie 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
stat $?

echo -n "Starting $COMPONENT service:"
systemctl enable mongod
systemctl restart mongod
stat $?

echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"
