# docker-tshock
---------------

A simple docker container for running a TShock Terraria server

## Installation
---------------

You can install the latest automated build by pulling the image from
the docker index.

```bash
docker pull kalhartt/tshock:latest
```

## Quick Start
--------------

The image is ready to go and will start a Terraria server with a medium sized
map. The Terraria server is open on port 7777 and the TShock rest-api is
available on port 7878. The server runs with all default settings, except the
rest-api is enabled.

```bash
docker run --name='tshock' -it -p 7777:7777 -p 7878:7878 kalhartt/tshock:latest
```

## Advanced Usage
-----------------

The Terraria server is launched with the arguments
`-world /opt/tshock/Terraria/Worlds/Default.wld -autocreate 2`. These arguments
can be overriden by passing any arguments to `docker run` like so:

```bash
docker run -it kalhartt/tshock:latest \
-world /opt/tshock/Terraria/Worlds/MyWorld.wld \
-maxplayers 16
```

It can be nice to have access to the world files outside of docker to ease
backups. This can be accomplished by using dockers volumes and some tshock
arguments. In this example, there is a local folder `Worlds` which we will
mount to the container at `/opt/tshock/Worlds`. This way all world files will
be accessible from both locally and inside the docker container.

```bash
docker run --name='tshock' -it \
-p 7777:7777 -p 7878:7878 \
-v Worlds:/opt/tshock/Worlds \
kalhartt/tshock:latest \
-world /opt/tshock/Worlds/MyWorld.wld \
-autocreate 2
```

It is also possible to use a custom config file using the same mechanism. In
this example, a local folder `config` contains the `config.json` file to be
used by the server.

```bash
docker run --name='tshock' -it \
-p 7777:7777 -p 7878:7878 \
-v config:/opt/tshock/config \
kalhartt/tshock:latest \
-world /opt/tshock/Worlds/Default.wld \
-autocreate 2 \
-config /opt/tshock/config/config.json
```
