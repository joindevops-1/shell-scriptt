#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date "+%Y-%m-%d-%H-%M-%S")
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE="/var/log/shellscript-logs/$SCRIPTNAME-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
N="\e[0m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "Please run this script with root priveleges" &>>$LOG
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N" &>>$LOG
        exit 1
    else
        echo -e "$2 is... $G SUCCESS $N" &>>$LOG
    fi
}

CHECK_ROOT

for package in $@
do
    dnf list installed $package
    if [ $? -ne 0 ]
    then
        echo "$package is not installed, going to install it.." &>>$LOG
        dnf install $package -y &>>$LOG
        VALIDATE $? "Installing $package"
    else
        echo "$package is already installed, nothing to do.." &>>$LOG
    fi
done

