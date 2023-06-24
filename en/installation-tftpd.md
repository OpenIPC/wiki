# OpenIPC Wiki
[Table of Content](../README.md)

Running a TFTP server in Docker
-------------------------------

The easiest way to run a TFTP server is to do that inside a containerized
environment. It does not matter if you run Linux, Windows, or Mac, just perform
these steps:

### Install Docker Composer
Follow the [Docker installation instructions][1].

### Create Docker image files
Create a file named `Dockerfile` with the following content:
```dockerfile
FROM debian:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install tftpd-hpa -y -qq && \
apt-get clean && rm -rf /var/lib/apt/lists/*

CMD echo -n "Starting $(in.tftpd --version)" && \
in.tftpd --foreground --create --secure --ipv4 --verbose --user tftp \
--address 0.0.0.0:69 --blocksize 1468 /srv/tftp
```

In the same directory, create a file named `docker-compose.yml` with the
following content:
```yaml
version: '3.9'
services:
  tftpd-hpa:
    build: .
    container_name: tftp
    network_mode: 'host'
    restart: unless-stopped
    volumes:
      - ./tftp:/srv/tftp
```

### Start the container
```bash
docker-compose up -d
```
Docker will build an image if necessary and launch it in the background. During
building the container, Docker will also create `tftp/` subdirectory from which
your files will be served. Docker acts as user `systemd-network` from group
`input` to access that directory. If you want to allow saving files sent via
TFTP to your machine you'll need to change ownership on that directory:
```bash
sudo chown systemd-network:input ./tftp
```
Alternatively, you may loosen permissions on that directory:
```bash
sudo chmod 777 ./tftp
```
Use your computer's IP address to access the TFTP server from other machines on
your local network.

### Stop the container
To stop the container and free up memory just run
```bash
docker-compose stop
```
The container will be saved on your computer until the next time you need to
start it.


[1]: https://docs.docker.com/compose/install/
