# Lesson 2: Mediawiki application with Docker

After Lesson 1, you should be familiar with Docker containers. Let's use Docker to deploy the Mediawiki application as a next step.

## Task:  Dockerfiles for Mediawiki

We will now use the scripts from exercise 4 (cloud-init) to deploy the mediawiki components. We will write one Dockerfile for each component (Database, Mediawiki Apache, Loadbalancer, Monitoring). We will reuse and extend existing Docker images of Docker Hub.

Create a new virtual machine and install Docker (or use the Docker VM from lesson 1). 
Download and extract the dockerfiles.zip file from Moodle and copy it into this virtual machine.
Inside the extracted folder, you find four folders, one for each component. 
Each sub folder contains a file called `Dockerfile` and some other files like configuration files or 
the database dump. Before we continue, open the file `Mediawiki/LocalSettings.php` and change the `$wgServer` to 
the floating ip of your virtual machine.

Let's now build Docker images from the Docker files:

```
docker build -t clouds/database ./Database
docker build -t clouds/mediawiki ./Mediawiki
docker build -t clouds/loadbalancer ./Loadbalancer
```

Validate that the images were created properly, via the command `docker images`.

Let's start a container for each component. Since the mediawiki container needs a reference to the database container, and the 
load balancer container needs a reference to the mediawiki container, we have to use the `--link` argument. 
The loadbalancer container exports its internal port 80 as external port 80.

```
docker run -d --hostname database --name database clouds/database
docker run -d --hostname web1 --name web1 --link=database clouds/mediawiki
docker run -d --hostname loadbalancer --name loadbalancer --link=web1 --publish 80:80 clouds/loadbalancer
```

Open a browser and navigate to http://YOUR_FLOATING_IP/wiki.

Troubleshooting: if something broke down, you can access the containers via `docker exec -ti web1 bash`, 
or get the `stdout` via `docker logs web1`.

## Questions: Experiences with Docker 

You have experiences with virtual machines on OpenStack, automated resource allocation with Terraform and automated
application deployment with cloud-init. Finally, we just 'dockered' the mediawiki example.

- Practically, where do you see benefits and drawbacks in the usage of virtual machines versus Docker containers? (E.g. creation time, image size, descriptiveness, ...)

- Looking at the cloud stack from the beginning of this exercise, why are the two layers "Cloud Platform" and "Virtual Resources" still necessary although we have containers? Or why are both layers not necessary when working with containers?


## Task: Extend the Dockerfiles for Mediawiki

The previous task provides no monitoring. Let's extend the Dockerfiles by monitoring.
We can use the existing Docker images for influxdb, telegraf and chronograf from Docker Hub.

```
docker run -d --hostname influxdb --name influxdb influxdb
docker run -d --hostname chronograf --name chronograf --link=influxdb --publish 8888:8888 chronograf
docker run -d --hostname=telegraf --name=telegraf --link=influxdb --link=web1 --link=loadbalancer --link=database \
    -e "HOST_PROC=/rootfs/proc" -e "HOST_SYS=/rootfs/sys" \
    -e "HOST_ETC=/rootfs/etc" \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v /sys:/rootfs/sys:ro -v /proc:/rootfs/proc:ro -v /etc:/rootfs/etc:ro \
    -v $(pwd)/Monitoring/telegraf.conf:/etc/telegraf/telegraf.conf:ro \
    telegraf
```

The chronograf dashboard should be available via http://YOUR_FLOATING_IP:8888/.

## Task: Use docker-compose as a simple orchestrator
So far we have created and linked the Docker containers manually. Docker compose [1] can help with automation.

First, install Docker compose in your virtual machine. Next, try to create a `docker-compose.yaml` file for the containers
we created manually. 

The empty skeleton will look like the following:

```
version: '2'
services:
    web1:
        build: Mediawiki
        image: clouds/mediawiki

    database:
        build: Database

    ...
```

The commands you would need to work with your Docker compose file are 
`docker-compose build`, `docker-compose up`, `docker-compose down`, ...


[1] https://docs.docker.com/compose/
