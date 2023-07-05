#!/bin/bash

#Get current user
USER_NAME=$USER
if (( $EUID != 0 )); then
  #Running as root
  USER_NAME="root"
fi

#Get the wine folder
WINE_PARENT_DIR=""
if (( $EUID != 0 )); then
  #Running as common user
  WINE_PARENT_DIR="/home/$USER"
else
  #Running as root
  WINE_PARENT_DIR="/root"
fi

#Compress the .wine folder
if ! [ -f ./hostwine.tar.gz ]; then
tar -C $WINE_PARENT_DIR -cvf hostwine.tar.gz .wine
fi

docker build --build-arg WINE_PARENT_DIR=$WINE_PARENT_DIR \
             --build-arg USER=$USER_NAME \
             -t personal \
             -f PersonalDockerfile\
             .     
