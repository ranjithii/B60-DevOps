#!/bin/bash

echo "Configuration Management for $COMPONENT in progress"

ID=$(id -u)
APPUSER="roboshop"
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


create_user() {
    id $APPUSER  &>> $LOG
    if [ $? -ne 0 ]; then
        echo -n "Creating roboshop user account :"
        useradd $APPUSER 
        stat $?
    else
        echo -n "SKIPPING"
    fi 
    stat $? 
}


download_and_extract() {
    echo -n "Performing cleanup of $COMPONENT :"
    rm -rf /app/ || true 
    stat $?

    echo -n "Creating APP directory :"
    mkdir /app
    stat $? 

    echo -n "Downloading the $COMPONENT app :"
    curl -o /tmp/${COMPONENT}.zip https://stan-robotshop.s3.amazonaws.com/${COMPONENT}-v3.zip  &>> $LOG
    stat $?

    echo -n "Extracting the $COMPONENT app"
    unzip -o /tmp/${COMPONENT}.zip -d /app/  &>> $LOG
    stat $?
}

config_svc() {
    echo -n "Configuring systemd for $COMPONENT :"
    cp ${COMPONENT}.service /etc/systemd/system/${COMPONENT}.service
    stat $?

    echo -n "Starting $COMPONENT service :"
    systemctl enable $COMPONENT &>> $LOG
    systemctl start $COMPONENT &>> $LOG
    stat $? 
}

install_monghShell() {
    echo -n "Configuring Mongo shell repo :"
    cp mongo.repo /etc/yum.repos.d/mongo.repo

    echo -n "Installing mongodb shell :"
    dnf install mongodb-mongosh -y &>> $LOG
    stat $?
}

install_mysql() {
    echo -n "Installing mysql :"
    dnf install mysql -y &>> $LOG
    stat $?
}

nodejs() {
    echo -n "Disabling the default nodejs version :"
    dnf module disable nodejs -y &>> $LOG
    stat $? 

    echo -n "Enabling the nodejs version 20 :"
    dnf module enable nodejs:20 -y &>> $LOG
    stat $? 

    echo -n "Installing Nodejs :"
    dnf install nodejs -y &>> $LOG
    stat $?

    create_user

    install_monghShell

    download_and_extract

    config_svc

    echo -n "Generating $COMPONENT Artifacts :"
    cd /app
    npm install &>> $LOG
    stat  $?
    
    if [ "$COMPONENT" == "catalogue" ]; then
        echo -n "Injecting the schema :"
        mongosh --host mongodb.krrinet.online </app/db/master-data.js &>> $LOG
        stat $? 
    fi 

    echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"

}

maven() {
    echo -n "Installing Maven :"
    dnf install maven -y &>> $LOG
    stat $?

    create_user

    download_and_extract
    
    echo -n "Generating $COMPONENT Artifacts :"
    cd /app
    mvn clean package  &>> $LOG
    mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar 
    cd -
    stat  $?
    
    install_mysql

    config_svc

    if [ "$COMPONENT" == "shipping" ]; then
        echo -n "Injecting the schema :"
        mysql -h mysql.krrinet.online -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOG
        stat $?
        echo -n "Injecting the appUser info :"
        mysql -h mysql.krrinet.online -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOG
        stat $?
        echo -n "Injecting the master-data info :"
        mysql -h mysql.krrinet.online -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOG
        stat $?
    fi 

    echo -e "\n \t ___ Configuration Management for $COMPONENT is completed! ___"
}

python() {
    echo -n "Installing Python3 :"
    dnf install python3 gcc python3-devel -y &>> $LOG
    stat $?

    create_user

    download_and_extract
    
    echo -n "Generating $COMPONENT Artifacts :"
    cd /app
    pip3 install -r requirements.txt &>> $LOG
    cd -
    stat  $?

    config_svc

    echo -e "\n \t ___ Configuration Management for $COMPONENT in completed! ___"
}
