#!/bin/bash

#Repo update
sudo apt update

#Install docker
sudo apt install docker.io

#Start and enable docker
sudo systemctl start docker
sudo systemctl enable docker 

#Check docker
sudo systemctl status docker
