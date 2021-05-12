# boinc-pi-zero
A lightweight BOINC client Docker container for ARMv6 32-bit architecture like Raspberry Pi Zero W

This repo is part of a fun project to make a Pi Zero Docker cluster with four Pi Zero's. BOINC does only publish a ARMv7 32-bit client which means you have to build your own.
I first tried this with a Alpine base image but at the time of writing Raspbian 32-bit does not support the new time64 fix for the 2038 problem. 
Next I tried to use the Docker images of resin/rpi-raspbian but they are tagged as AMD64 and will only start at a single Pi but not in a swarm. So I extracted the files of the buster image, removed a lot of not needed documentation and created a buster.tgz for use in a Dockerfile.

The result of the docker build can be found at https://hub.docker.com/r/synoniem/boinc-pi-zero. You can use this image to run Docker in Swarm mode with the following commands without the # comments:
```sh
# One time
docker swarm init
docker network create -d overlay --attachable boinc

# Every service start
docker service create \
  --replicas <N> \                                              # Number of instances
  --name boinc \
  --network=boinc \
  --mount type=volume,source=boinc,destination=/var/lib/boinc \ # Create persistant storage to save your work
  --replicas-max-per-node 1 \                                   # You can only have one BOINC persistant storage per node
  -p 31416:31416 \
  -e BOINC_REMOTE_HOST="0.0.0.0" \                              # Default the whole internet. Limit it to your own taste.
  -e BOINC_GUI_RPC_PASSWORD="123" \                             # Choose your own
  -e BOINC_CMD_LINE_OPTIONS="--allow_remote_gui_rpc" \
  -e TZ=UTC \                                                   # Default is UTC
  synoniem/boinc-pi-zero
```
You can send commands to the cluster by using the boinccmd_swarm command which will execute boinccmd at every running instance.
As a example adding your project to the running containers use:
```sh
docker run --rm --network boinc synoniem/boinc-pi-zero boinccmd_swarm --passwd 123 --project_attach https://project.url account_key
```
More information about the boinccmd command is available at https://boinc.berkeley.edu/wiki/Boinccmd_tool

To build your own image clone this repo and execute the following command:
```sh
docker build . --platform linux/arm/v6 -t tagname
```

To launch your own image as a service you need to push it to a registry which is reachable from the clients. For details look at the Docker documentation.
