#!/bin/bash

#No debug output for wine
WINEDEBUG=-all

#Add the i386 arch to dpkg
sudo dpkg --add-architecture i386

#Include the winehq repo
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources

#Update repos
sudo apt update

#Install wine
sudo apt install --install-recommends winehq-stable

#Test wine
echo "Close the clock app to continue..."
sudo wine clock
echo "Wine is ready!"

#Install winetricks
sudo apt-get install winetricks -y

#Install dotnet
sudo winetricks dotnet40
sudo winetricks dotnet45

#Remove the Documents synlink
sudo rm /root/.wine/drive_c/users/root/Documents
sudo mkdir /root/.wine/drive_c/users/root/Documents

#Configure wine to Windows 10
echo "Setup wine to Windos 10"
sudo wine winecfg

#Run the docker4delphi app
sudo chmod +x ./delphi4dockercli
sudo ./delphi4dockercli
