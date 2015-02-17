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

A bash script is included to help launch and manage tshock servers using this
container. Note the script requires `expect` to be installed, and the running
user must have docker permissions. To start a server just do the following:

```bash
wget https://raw.githubusercontent.com/kalhartt/docker-tshock/master/tshock.sh
chmod +x tshock.sh

# Start the server
./tshock.sh start servername

# Attach the server (ctrl-p ctrl-q to detach)
./tshock.sh attach servername

# stop the server
./tshock.sh stop servername
```

Where `servername` is a name of your choice. This will create a directory at
`$HOME/servername` to store your world files, logs, and config files. You can
start the server with custom options as listed below:

```bash
$ ./tshock.sh
Usage:
    tshock [-g PORT] [-p PORT] [-d BASEDIR] start NAME
    tshock attach NAME
    tshock stop NAME

Options:
    NAME        Name of the docker container
    -d BASEDIR  Directory for mounted volumes (default: $HOME/NAME)
    -p PORT     Port to bind terraria server to (default: 7777)

$ ./tshock -p 1234 -d /abs/path/to/server start myserver
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
