#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date "+%Y-%m-%d-%H-%M-%S")
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
mkdir -p /var/log/shellscript-logs
LOGFILE="/var/log/shellscript-logs/$SCRIPTNAME-$TIMESTAMP.log"
R="\e[31m"
G="\e[32m"
N="\e[0m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "Please run this script with root priveleges" | tee -a $LOGFILE
        exit 1
    fi
}

USAGE(){
    echo "USAGE: $0 package1 package2 ..."
    exit 1
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N" | tee -a $LOGFILE
        exit 1
    else
        echo -e "$2 is... $G SUCCESS $N" | tee -a $LOGFILE
    fi
}

if [ $# -eq 0 ]
then
    USAGE
fi

echo "script started executing at: $(date)" | tee -a $LOGFILE

CHECK_ROOT

for package in $@
do
    dnf list installed $package &>>$LOGFILE
    if [ $? -ne 0 ] 
    then
        echo "$package is not installed, going to install it.." | tee -a $LOGFILE
        dnf install $package -y &>>$LOGFILE
        VALIDATE $? "Installing $package"
    else
        echo "$package is already installed, nothing to do.." | tee -a $LOGFILE
    fi
done

