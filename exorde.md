# INSTALL EXORDE

* Exorde Installation for Ubuntu Server 22.04 LTS

## Create User for Exorde
```sh
sudo adduser exorde
sudo usermod -aG sudo exorde
su - exorde
```

## Install required packages
```sh
sudo apt update && sudo apt upgrade -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common
sudo apt install -y build-essential libssl-dev libffi-dev git curl screen
```

## Install Docker
```sh
curl -fsSL https://get.docker.com/ -o get-docker.sh
chmod +x ./get-docker.sh
sudo ./get-docker.sh # RInstall Docker
sudo usermod -aG docker $USER
```


## Download remote repo
```sh
git clone https://github.com/exorde-labs/ExordeModuleCLI.git
```

## Build Exorde (takes a while)
```sh
cd ExordeModuleCLI
docker build -t exorde-cli .
```

Resulting lines should be as follows:
```
...
Removing intermediate container 87535c405c84
 ---> 2c1bf7dc048e
Step 7/7 : ENTRYPOINT [ "python", "./Launcher.py"]
 ---> Running in cca98ea52856
Removing intermediate container cca98ea52856
 ---> 9af5ea26d586
Successfully built 9af5ea26d586
Successfully tagged exorde-cli:latest
```

## Enable Docker service
```sh
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

## Create and run Exorde container

Use a test Metamask wallet to run Exorde in Docker.
Replace `METAMASK_WALLET_ADDRESS` with yours.

```sh
docker run -d -e PYTHONUNBUFFERED=1 --restart always --name exorde-cli exorde-cli -m METAMASK_WALLET_ADDRESS -l LOGGING
```

* We set `--restart always` to restart docker if it fails because of the error below:

```
[Validation] Worker 0xc42F562ef4b597F5B5AfA9ECE435B056B8DEC33f Not registered
[Validation] DataSpotting contract instanciated
Initialization error Something went wrong while registering your worker address on the Validation Worksystem.
Please try restarting your application.
```


# How to update?

```sh
docker stop exorde-cli # stop running container
docker rm -f exorde-cli # remove the container
cd ~/ExordeModuleCLI
git pull # pull update from github
docker build -t exorde-cli . # build
# create and run new container
docker run -d -e PYTHONUNBUFFERED=1 --restart always --name exorde-cli exorde-cli -m METAMASK_WALLET_ADDRESS -l LOGGING
```

## USEFUL COMMANDS:

* View the logs: `docker logs --follow exorde-cli`
* Stop Exorde: `docker stop exorde-cli`
* Remove your Exorde container: `docker rm exorde-cli`
* Start the Exorde container: `docker start exorde-cli`
* Restart the Exorde container: `docker restart exorde-cli`
* List all containers (Running and stopped): `docker ps -a`
* List containers (Running only): `docker ps`