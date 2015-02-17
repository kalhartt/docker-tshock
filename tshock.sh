#!/usr/bin/env bash
##########
# Default Options
##########
IMAGE="kalhartt/tshock:latest"
CONTAINER=""
BASEDIR=""
WORLD="world0.wld"
GAMEPORT="7777"
RESTPORT="7878"


##########
# usage
# Print usage message and exit with status 1
##########
usage () {
cat << EOF
Usage:
    tshock [-g PORT] [-p PORT] [-d BASEDIR] start NAME
    tshock attach NAME
    tshock stop NAME

Options:
    NAME        Name of the docker container
    -d BASEDIR  Directory for mounted volumes (default: $HOME/NAME)
    -p PORT     Port to bind terraria server to (default: 7777)
    -r PORT     Port to bind REST API to (default: 7878)
EOF
exit 1
}

##########
# running NAME
# Check if a container named NAME is running
# Returns status 0 if running, otherwise 1
##########
running () {
    docker inspect -f {{.State.Running}} "$1" 2> /dev/null \
	| grep true &> /dev/null
}

##########
# stopcontainer NAME
# Gracefully stop tshock container named NAME
##########
stopcontainer () {
expect << EOF
spawn docker attach ${CONTAINER}
send "\\off\r"
expect eof
EOF
}

##########
# Parse Options
##########
while getopts hp:r:d: FLAG; do
    case "${FLAG}" in
	h)
	    usage
	    ;;
	p)
	    GAMEPORT="${OPTARG}"
	    ;;
	r)
	    RESTPORT="${OPTARG}"
	    ;;
	d)
	    BASEDIR="${OPTARG}"
	    ;;
    esac
done

shift $(($OPTIND - 1))

if [[ "$#" -lt "2" ]]; then
    usage
fi

ACTION="$1"
CONTAINER="$2"

if [[ -z "${BASEDIR}" ]]; then
    BASEDIR="${HOME}/${CONTAINER}"
fi

##########
# Main Script
##########
case "${ACTION}" in
    start)
	if running ${CONTAINER}; then
	    echo "${CONTAINER} already running"
	    exit 1
	fi
	echo "Starting ${CONTAINER}"
	mkdir -p ${BASEDIR}/{worlds,logs,config}
	docker run --name="${CONTAINER}" -itd \
	    -p ${GAMEPORT}:7777 \
	    -p ${RESTPORT}:7878 \
	    -v ${BASEDIR}/worlds:/opt/tshock/worlds \
	    -v ${BASEDIR}/logs:/opt/tshock/logs \
	    -v ${BASEDIR}/config:/opt/tshock/config \
	    ${IMAGE} \
	    -configpath /opt/tshock/config \
	    -logpath /opt/tshock/logs \
	    -worldpath /opt/tshock/worlds \
            -world /opt/tshock/worlds/${WORLD} \
	    -autocreate 2 2> /dev/null || \
	    docker start ${CONTAINER}
	;;
    attach)
	if ! running ${CONTAINER}; then
	    echo "${CONTAINER} not running"
	    exit 1
	fi
	echo "Attaching ${CONTAINER}, press Ctrl-p Ctrl-q to detach"
	docker attach ${CONTAINER}
	;;
    stop)
	if ! running ${CONTAINER}; then
	    echo "${CONTAINER} not running"
	    exit 1
	fi
	echo "Stopping ${CONTAINER}"
	# Try to gracefully shutdown the server
	# fallback to force kill after 10 seconds
	( sleep 10 && docker stop ${CONTAINER} &> /dev/null $$ ) &
	stopcontainer ${CONATINER}
	;;
esac
