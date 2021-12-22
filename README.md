# foundryvtt_docker_script
Script for installing docker, docker-compose and creation of required directories for the docker container of foundry.

## Information
The script upgrades the OS and installs docker.io and docker-compose.
Also it creates the directory path /data/foundry and start, restart, stop and upgrade-script in the subdir server_scripts.
After running the script there should be a docker instance running containing the current foundryvtt docker container from https://hub.docker.com/r/felddy/foundryvtt with the "release" tag. The container uses your login name and password of your foundryvtt.com account to pull your associated licence from your account. You will not be able to run the script without having a licence in your account.
For further documentation about the used enviroment variables in the docker-compose file or help regarding the image head to https://github.com/felddy/foundryvtt-docker. 

Special thanks to felddy(https://github.com/felddy) for providing the docker image.

## Prerequisites
This script is tested with Ubuntu 20.04 but should work with any Debian-based Distribution.
I'm running my instance on a small cloud server with 1vCore and 2GB of RAM. The attached storage has to meet your space requirements. My hoster of choise is https://hetzner.cloud/?ref=AuGEocp8cyzA. This link is a referral link and I'd be happy if you use this link to create your account.

Be sure to add the required DNS entry to your domain hoster pointing to the public ipv4-address of your server (Hetzner also offers domains).
Also be sure to forward port 80 and 443 to your server as it is required to obtain the ssl-certificate.

Prefill the variables in the script to run it properly. You have to fill all the values as they are needed to run this deployment. If you don't want to use ssl encryption or change ports, values etc. to your needs, feel free to change the script as needed.

## Installation
Download the script to a directory of your choise.
Then execute the following command to give execution rights:
```
chmod +x install_and_run_foundry.sh
```
After executing the command you are able to run the script with
```
sh install_and_run_foundry.sh
```
Now check with ```docker ps``` if your instance is running. The output should look like this:
```
CONTAINER ID   IMAGE                       COMMAND                  CREATED          STATUS                    PORTS                                           NAMES
abcdefghijkl   felddy/foundryvtt:release   "./entrypoint.sh res…"   22 minutes ago   Up 22 minutes (healthy)   0.0.0.0:30000->30000/tcp, :::30000->30000/tcp   foundry_foundry_1
```
Finally you can access your instance with the domain specified.

### Starting, restarting and stopping your instance
Just run the specific script in the /data/foundry/server_scripts directory.

### Upgrading your instance
The upgrade can't be done from the webinterface, as it's running in a docker container.
Run the upgrade script from the server_scripts directory. Be sure to backup your data before upgrading to the latest version. Also remember, that some of the plugins may not work or may need refatoring of the settings after upgrading. 

### Using specific images
Just change the tag of the image in the variable section of the script and run the update script. You can get the available tags here: https://hub.docker.com/r/felddy/foundryvtt.
If this is the first run of the script you don't have to run the update script.
Remeber to change the release version in the ```docker-compose.yml``` file if you want to run another version afterwards.

## Backup and restore
### Backing up your data
Stop the container and then copy all files from /data/foundry to a destination of your choise (preferrably not on the same server).

### Restoring your data
Stop the container, copy your backup to /data/foundry, execute ```chown -R foundry:foundry /data/foundry``` and then start the container. Be sure to only restore data with the same or lower version than the running container.

## Support
For support regarding the script just open an issue here on github.
For support regarding the docker image head to the github repository of felddy.
For support regarding foundryvtt head to the website https://foundryvtt.com
