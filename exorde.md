# INSTALL EXORDE

**NOTE:** Tested on Ubuntu Server 22.04 LTS

## Create User for Exorde
```sh
sudo adduser exorde
sudo usermod -aG sudo exorde
su - exorde
```

## Install required packages
```sh
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl
```

## Install Docker
```sh
curl -fsSL https://get.docker.com/ -o get-docker.sh
chmod +x ./get-docker.sh
sudo ./get-docker.sh # Install Docker
sudo usermod -aG docker $USER
```

**Enable Docker service**
```sh
sudo systemctl enable --now docker.service
sudo systemctl enable --now containerd.service
```

**NOTE:** At this point, you may need to log out & in your linux account.

## Easy Install

```sh
docker run -d --restart unless-stopped --pull always --name exorde-cli exordelabs/exorde-cli -m METAMASK_WALLET_ADDRESS -l 2
```
If you choose this method, no need to install from github. Ignore the rest of this tutorial.

## Install from github

### Download remote repo
```sh
git clone https://github.com/exorde-labs/ExordeModuleCLI.git
```

### Build Exorde
This will take a while...
```sh
cd ExordeModuleCLI
sudo docker build -t exorde-cli .
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

### Create and run Exorde container

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


## How to update?

```sh
docker stop exorde-cli # stop running container
docker rm -f exorde-cli # remove the container
cd ~/ExordeModuleCLI
git pull # pull update from github
docker build -t exorde-cli . # build
# create and run new container
docker run -d -e PYTHONUNBUFFERED=1 --restart always --name exorde-cli exorde-cli -m METAMASK_WALLET_ADDRESS -l 2
```

## USEFUL COMMANDS:

* View the logs: `docker logs --follow exorde-cli`
* Stop Exorde: `docker stop exorde-cli`
* Remove your Exorde container: `docker rm exorde-cli`
* Start the Exorde container: `docker start exorde-cli`
* Restart the Exorde container: `docker restart exorde-cli`
* List all containers (Running and stopped): `docker ps -a`
* List containers (Running only): `docker ps`

## REFERENCES:
* [Exorde Github](https://github.com/exorde-labs/ExordeModuleCLI)
* [Exorde Leaderboard](https://explorer.exorde.network/leaderboard)
* [Leaderboard](https://explorer.exorde.network/leaderboard)
* [Skale Node list](https://light-vast-diphda.explorer.mainnet.skalenodes.com/)
* [Exorde Bitcoin Price Prediction](https://exorde.io/bitcoin)