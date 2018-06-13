# Lesson 2: Mediawiki application with Docker

After Lesson 1, you should be familiar with Docker containers. Let's use Docker
to deploy the Mediawiki application as a next step.

## Task: Dockerfiles for Mediawiki

We will now use the scripts from exercise 4 (cloud-init) to deploy the mediawiki
components. We will write one Dockerfile for each component (Database, Mediawiki
Apache, Loadbalancer, Monitoring). We will reuse and extend existing Docker
images of Docker Hub.

Create a new virtual machine with Ubuntu 16.04 and install Docker (or use the
Docker VM from lesson 1). Make sure to allow incoming tcp access to port 80.
Download and extract the dockerfiles.zip file from Moodle and copy it into your
virtual machine. Inside the extracted folder, you find four folders, one for
each component. Most sub folders contain a file called `Dockerfile`, and some
other files like configuration files or the database dump. Before we continue,
open the file `Mediawiki/LocalSettings.php` and change the `$wgServer` to the
floating ip of your virtual machine.

Let's now build Docker images from the Docker files. Navigate into the
`dockerfiles` folder of the extracted dockerfiles.zip archive.

```
docker build -t clouds/database ./Database
docker build -t clouds/mediawiki ./Mediawiki
docker build -t clouds/loadbalancer ./Loadbalancer
```

Validate that the images were created properly, via the command `docker images`.

```
REPOSITORY            TAG                 IMAGE ID            CREATED              SIZE
clouds/loadbalancer   latest              eb626e2194a5        2 seconds ago        109MB
clouds/mediawiki      latest              82b8228794b8        27 seconds ago       446MB
clouds/database       latest              48476b1997a0        About a minute ago   279MB
...
```

Let's start a container for each main component (database, webserver,
loadbalancer). Since the mediawiki container needs to connect to the database
container, and the load balancer container has to point to the mediawiki
container, we have to use the `--link` argument to reference them automatically.
Inside the containers, die linked container is then known by the specified name.
Finally, the loadbalancer container has to export its internal port 80 as
external port 80.

```
docker run -d --hostname database --name database clouds/database
docker run -d --hostname web1 --name web1 --link=database clouds/mediawiki
docker run -d --hostname web2 --name web2 --link=database clouds/mediawiki
docker run -d --hostname loadbalancer --name loadbalancer --link=web1 \
    --link=web2 --publish 80:80 clouds/loadbalancer
```

Validate with `docker ps -a` that all containers are running. Open a browser and
navigate to http://YOUR_FLOATING_IP/wiki/index.php/Main_Page. You should a
working Mediawiki.

Troubleshooting: if something broke, you can access the containers via `docker
exec -ti web1 bash`, or get the `stdout` via `docker logs web1`.

## Questions: Experiences with Docker

Since the beginning of the exercises you made experiences with virtual machines
on OpenStack, automated resource allocation with Terraform and automated
application deployment with cloud-init. Finally, we just 'dockered' the
Mediawiki example.

- Practically, where do you see benefits and drawbacks in the use of virtual
  machines versus Docker containers? (E.g. creation time, image size,
  descriptiveness, ...)

- Looking at the cloud stack from the beginning of this exercise, why are the
  two layers "Cloud Platform" and "Virtual Resources" still necessary although
  we have containers? Or why are both layers not necessary when working with
  containers?


## Task: Extend the Monitoring

The previous task provides no monitoring. Let's extend the three existing
containers by monitoring. We can use the existing Docker images for influxdb,
telegraf and chronograf from Docker Hub.

```
docker run -d --hostname influxdb --name influxdb influxdb
docker run -d --hostname chronograf --name chronograf --link=influxdb \
    --publish 8888:8888 chronograf
docker run -d --hostname=telegraf --name=telegraf --link=influxdb \
    --link=web1 --link=web2 --link=loadbalancer --link=database \
    -e "HOST_PROC=/rootfs/proc" -e "HOST_SYS=/rootfs/sys" \
    -e "HOST_ETC=/rootfs/etc" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /sys:/rootfs/sys:ro -v /proc:/rootfs/proc:ro -v /etc:/rootfs/etc:ro \
    -v $(pwd)/Monitoring/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
    telegraf
```

The chronograf dashboard should be available via http://YOUR_FLOATING_IP:8888/.
Make sure that your security groups allow incoming tcp connections on port 8888.
The Chronograf dashboard has to be configured with connection string
"http://influxdb:8086" some namy and Telegraf database "telegraf".

## Task: Use docker-compose as a simple orchestrator
So far we have created and linked the Docker containers manually. Docker compose
[1] can help with automation.

First, install Docker compose in your virtual machine (see [1]). Become familiar
with the basic usage of Docker compose. Next, try to create a
`docker-compose.yaml` file for the containers we created manually.

The empty skeleton will look like the following:

```
version: '2'
services:
    web1:
        build: Mediawiki
        image: clouds/mediawiki
        ...

    database:
        build: Database
        ...
    ...
```

The commands you would need to work with your Docker compose file are
`docker-compose build`, `docker-compose up`, `docker-compose down`, ...

[1] https://docs.docker.com/compose/

## Question: Docker distributed

So far we used one virtual machine to host all the Docker containers.
This will of course not scale eventually.

Can you find a solution to distribute Docker containers on multiple hosts?
