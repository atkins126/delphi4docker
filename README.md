# delphi4docker
Step-by-step guide to create your own Docker container to compile Delphi projects

Host Delphi on a Docker container and compile Delphi projects for Windows, Mac, Linux, Android and iOS (Not Tested) from the container

https://github.com/lmbelo/delphi4docker/assets/8376898/e8d4ba26-4542-4f2b-86df-f2b40a73f2a3

# Requirements
- Valid Embarcadero licence for Delphi
- A fresh Windows 10 virtual machine
- A fresh Ubuntu 20.04 virtual machine
- Consider having 150GB HDD space available for each VM

# Caveats
- Use the same user name in your VMs as your docker container. I strongly recomend you to use root as user
  	* In your Windows machine, create a user called root
  	* In your Ubuntu machine, run everything as root
- If you’re using Mac and Parallels for managing VMs, use the option “Isolate Windows from Mac”
- Tested using Delphi 11.3 only. For the previous version of Delphi, it might not work because Eclipse Adoptium folder doesn’t exist

# Setting up for Windows VM
- Install Delphi as a regular installation (Uncheck the option “Install for all users” and use the default destination folder)
<img src="https://github.com/lmbelo/delphi4docker/assets/8376898/2b02af26-1007-410f-857a-cd7847f72202" width="460">

- Install all the required getit packages and SDKs
- Install all available patches
- Remove everything that is IDE only related to [size down your bundle](https://github.com/lmbelo/delphi4docker/wiki/Sizing-down-your-bundle)
- Clone or download the repository: https://github.com/lmbelo/delphi4docker 
- Launch the app > delphi4dockersrv.exe app and use the Pack option
  - If you didn’t use the default options during the Delphi installation process, please set up accordingly. Whereas, if you used default options, you can go ahead and use the Pack option
<img width="400" heigh="400" alt="image" src="https://github.com/lmbelo/delphi4docker/assets/8376898/0600ba01-2dd0-4259-9472-a894399fd16b">


- It will now pack the Delphi environment and bundle it up to a single file and make it ready to send to the Ubuntu host machine
- When done, a message will display
<img width="400" heigh="400" alt="image" src="https://github.com/lmbelo/delphi4docker/assets/8376898/c57d66b3-6f1c-4871-a989-9b0831f90910">

# Setting up for Ubuntu 20.04 VM
## Installing WINE

**Note: You can simplify this process running the setup_wine.sh script**

- Verify 64-bit architecture. The following command should respond with "amd64"
``` shell
$ dpkg --print-architecture
```
- See if 32-bit architecture is installed. The following command should respond with "i386"
``` shell
$ dpkg --print-foreign-architectures
```
- If "i386" is not displayed, execute the following
``` shell
$ sudo dpkg --add-architecture i386
```
- Recheck with.
``` shell
$ dpkg --print-foreign-architectures
```
- Download and add the WineHQ repository key
``` shell
$ sudo mkdir -pm755 /etc/apt/keyrings
$ sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
```
- Download the WineHQ sources file
``` shell
$ sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/focal/winehq-focal.sources
```
- Update the package database
``` shell
$ sudo apt update
```
- Install Wine
``` shell
$ sudo apt install --install-recommends winehq-stable
```
- When installing wine, as you get this screen, click on “**Cancel**” button
<img width="260" alt="image" src="https://github.com/lmbelo/delphi4docker/assets/8376898/30cc3bed-59fd-487e-b36b-aee0fc52b34d">
  
- Verify the installation succeeded
``` shell
$ wine --version
```
- Simple tests
  - To make sure wine is working
  - Display a simple clock
``` shell
$ wine clock
```
- Under wine: Install Microsoft.NET v4.0 and v4.5
``` shell
$ sudo apt-get install winetricks -y
```
``` shell
$ winetricks dotnet40
$ winetricks dotnet45
```
- Configure Wine to Windows 10
``` shell
$ wine winecfg
```
- Open Windows using
`-> Applications tab -> Windows version -> Windows 10`
<img width="299" alt="image" src="https://github.com/lmbelo/delphi4docker/assets/8376898/a2126380-d783-41e1-b9b2-ef809c4c8d67">

- Clone or download the repository: https://github.com/lmbelo/delphi4docker
- Run delphi4dockercli 
  - Setup the delphi4dockercli options
  - If you’ve followed the prescribed default settings in the above steps, you just need to set up the “Host Addr” option
  - Goto Window VM and click on “Send” button in the delphi4dockersrv application
  - Now press on the Receive button in the delphi4dockercli in Ubuntu VM
  <img width="570" alt="image" src="https://github.com/lmbelo/delphi4docker/assets/8376898/a780760f-df43-416d-8a76-0770061f56d0">

  - Wait until the operation finish and press on the “Upack and Setup” button
  <img width="350" alt="image" src="https://github.com/lmbelo/delphi4docker/assets/8376898/8c32b594-db9d-4a6c-90fe-b18f532e7bcb">

## Testing your environment

### Compiling a Test Project

- Enter the windows command prompt using the wine cmd command
- Run the path\to\rsvars.bat as mentioned in the below image. This will configure the MSBuild
- You can now compile the Test project using the msbuild
- **Recommendation:** Place your test projects into the path\to\Embarcadero\Studio\Projects\ folder
- You can configure the “Test Projects Folder” when bundling your Delphi environment using your Windows VM using the delphi4dockersrv application
- Finally you can see the result of your test project compilation as you can observe in the image below
<img width="750" alt="image" src="https://github.com/lmbelo/delphi4docker/assets/8376898/acc4d7e6-86a1-421a-b0f5-fdf44ea6d21c">

## Installing and Configuring Docker

Before creating the docker container, we will install the Docker to our Ubuntu 20.04 system, which is available by default in the Ubuntu repository

**Note: You can simplify this process running the setup_docker.sh script**

Update all packages list on the Ubuntu repository and install Docker using the apt command below
``` shell
$ sudo apt update
$ sudo apt install docker.io
```
Once all installation is completed, start the Docker service and add it to the system boot
``` shell
$ systemctl start docker
$ systemctl enable docker
```
Now check the Docker service using the command below
``` shell
$ systemctl status docker
```
The Docker service is up and running on Ubuntu 22.04

Next, run the docker command below to ensure the installation is correct
```shell
$ docker run hello-world
```
Below is the result you will get.
``` shell
Hello from Docker!
This message shows that your installation appears to be working correctly

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub
	(amd64)
 3. The Docker daemon created a new container from that image which runs the
	executable that produces the output you are currently reading
 4. The Docker daemon streamed that output to the Docker client, which sent it
	to your terminal

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

As can be seen, you get the Hello World message from Docker, and the Docker installation on Ubuntu 20.04 has been completed successfully

# Create a Docker Image using the Delphi Bundle

- Open the **docker > PersonalDockerfile** from the cloned delphi4docker repo. Edit the file as needed and configure your Docker image
- You’ll start with the base image as you can see in the “**Download Delphi base image**” section
- An important step is to copy the host wine prefix that you’ve set up using the above steps. This step is already provided as part of the dockerfiles under the “**Copy host wine**” section. So you need not edit this
- After that run the **docker > PersonalDockerbuild** using:
``` shell
$ ./PersonalDockerBuild
```
- Above step will clone the wine from your Ubuntu machine and create a docker image with Delphi compiler for you. This step will take a long time and require a lot of disk space
<img width="504" alt="image" src="https://github.com/lmbelo/delphi4docker/assets/8376898/d68eedd4-902c-4b2d-9542-2b82104c1f69">
  
- Please keep in mind that you can’t distribute the above-created docker image publicly because of license limitations. You can use it for your personal uses as you have the necessary Emabarcadero license





