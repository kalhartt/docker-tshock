# Dockerfile for a TShock Terraria Server
# https://github.com/kalhartt/docker-tshock
FROM mono:3.10.0
MAINTAINER kalhartt <kalhartt@gmail.com>

# Install unzip package
RUN apt-get -qq update && \
    apt-get -qqy install unzip

# Download and setup TShock
RUN curl -sL https://github.com/NyxStudios/TShock/releases/download/v4.2301/TShock.4.2.3.0720.zip > /tmp/TShock.4.2.3.0720.zip && \
    unzip /tmp/TShock.4.2.3.0720.zip -d /opt/tshock
COPY config.json /opt/tshock/tshock/config.json


# Start the server and expose the port
EXPOSE 7777 7878
WORKDIR /opt/tshock
ENTRYPOINT ["mono", "--server", "--gc=sgen", "-O=all", "TerrariaServer.exe"]
CMD ["-world", "Terraria/Worlds/Default.wld", "-autocreate", "2"]
