# Lesson 1: Concept of Containers

Our Cloud Stack so far had three layers: Cloud Platform, Virtual Resource, and Application Component. 
This means, that the applications are installed directly on top of the virtual operating system. 
In this lesson we will introduce a fourth layer: the application components are no longer 
installed on the operating system but are deployed inside containers.

| Cloud Stack | Example | Deployment Tool | 
| --- | --- | --- |
| **Application Component** | Mediawiki | (Bash) scripts |
| **Containers** | Docker | Dockerfile |
| **Virtual Resource** | Instance m1.small | Terraform |
| **Cloud Platform** | OpenStack | - |

## Research: What are containers and why to use them?

Before we start to work with containers, we need to understand why containers exist, and what
their benefits are. This blog post [1] gives a nice introduction. The most popular container software
is Docker. On the Docker page, they compare containers and virtual machines and how they fit together [2].

In the practical part of this exercise we will use Docker [3] and LXC [4] as container software. Become familiar
with both tools, to understand their similarities and differences.

[1] https://www.digitalocean.com/community/tutorials/the-docker-ecosystem-an-overview-of-containerization

[2] https://www.docker.com/what-container

[3] https://www.docker.com/

[4] https://linuxcontainers.org/

## Question: Containers, LXC and Docker

 - What architectural implications are required for an application to run in containers?

 - What are pros/cons of containers compared to virtual machines?

## Task: Create Containers with LXC

Clean up your bwcloud workspace: remove unnecessary virtual machines, release floating IPs, remove unused snapshots.

Create a new virtual machine named "lxc" in bwcloud with flavor m1.small from Ubuntu 16.04, and log into this VM via SSH. 
Inside the VM, let's install software for LXC. We will follow the official _lxc getting started guide_ [1]

```
sudo apt-get update
sudo apt-get install -y lxc

# some configurations needed
sudo echo "ubuntu veth lxcbr0 10" >> /etc/lxc/lxc-usernet
mkdir -p ~/.config/lxc
cp /etc/lxc/default.conf ~/.config/lxc
echo "lxc.id_map = u 0 $(cat /etc/subuid | grep ubuntu | cut -d ':' -f 2,3 | tr ':' ' ')
lxc.id_map = g 0 $(cat /etc/subgid | grep ubuntu | cut -d ':' -f 2,3 | tr ':' ' ')" \
    >> ~/.config/lxc/default.conf

# reboot the vm
sudo reboot
```

Lets create and start an LXC container according to [1]:

```
# create the container
lxc-create -t download -n my-container2
# e.g. select Distribution: ubuntu, Release: xenial, Architecture: i386

# validate that the container exists and is STOPPED
lxc-ls -f

# start the container
lxc-start -n my-container -d

# validate that the container is now RUNNING
lxc-ls -f

# Count the number of processes in the VM
ps -ef | wc -l

# log into the container
lxc-attach -n my-container

# Count the number of processes in the container
ps -ef | wc -l

# Check the networking inside the container
ip addr show

# exit container
exit

# stop and destroy container
lxc-stop --name my-container
lxc-destroy --name my-container
```

The newest version of lxc provides besides the lxc-{create,start,ls,stop,destroy,...} commands also the `lxc` command [2]:

```
# browse images
lxc image list images

# launch a container
lxc launch ubuntu:16.04 web1

# limit container to 1 cpu core
lxc config set web1 limits.cpu 1

# log in and install a web server
lxc exec web1 bash
apt-get install -y apache2
exit

# clone the container to web2
lxc copy web1 web2
lxc start web2

# list the containers
lxc list
```

As you can see, lxc containers can be cloned very quickly, which allows a fast and flexible scale out of application components.
The lxc commands can be called by a script to automate the deployment and management of lxc containers.

[1] https://linuxcontainers.org/lxc/getting-started/

[2] https://www.jamescoyle.net/cheat-sheets/2540-lxc-2-x-lxd-cheat-sheet

## Question: LXC Containers

- Where are more processes running: on the vm operating system or inside the container? And why?

- How does the networking look like? Why is it a good idea to have a private IP for each containers?

- What resources can be limited via `lxc config set [container] limits.*` command?


## Task: Create Containers with Docker

Create a new virtual machine named "docker" in bwcloud with flavor m1.small from Ubuntu 16.04, and log into this VM via SSH. 
Inside the VM, let's install software for Docker [1].

```
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce

sudo usermod -aG docker ubuntu
sudo systemctl enable docker
sudo systemctl start docker
```

You can validate that docker is installed by checking the version `docker --version` (should be something like 17.03.1-ce).
_Before we continue, log out and log in again via ssh._
Next, let's create a container and explore the docker commands ...


```
# create and start a container
docker run -d --name web1 ubuntu:16.04 sleep infinity

# list containers
docker ps -a

# list images
docker images

# attach to container and install webserver
docker exec -ti web1 bash
apt-get update
apt-get install -y apache2
exit

# Store container as an image
docker commit web1 myweb:v1

# list images
docker images

# Start another container from this image
docker run -d --name web2 myweb:v1

# do some more experiments ... 
# can you manage to access the web servers?
# hint: docker run has a port forwarding parameter

# stop and remove container
docker stop web1 web2
docker rm web1 web2
```

Besides installing containers manually, Docker introduces the `Dockerfile` - a build description
for docker containers. Let's try to build an example from a Dockerfile.

Create a folder `docker-test` in the home directory of your docker vm. Create and open a file `Dockerfile` inside the
`docker-test` folder and place the following content:

```
FROM ubuntu:16.04
RUN apt-get update; apt-get install -y apache2
RUN mkdir /opt/init
RUN echo '#!/bin/bash \nset -x \n/usr/sbin/apache2ctl -DFOREGROUND' > /opt/init/entrypoint
RUN chmod +x /opt/init/entrypoint
ENTRYPOINT "/opt/init/entrypoint"
```

Next, let's build an image from this Dockerfile and start a new container. Inside the folder `docker-test`:

```
# Build the image
docker build -t myreg/web .

# list images
docker images

# start container
docker run -d --name web1 myreg/web
```

Docker Hub [2] is a central registry for Docker images. Tons of per-packaged software is available
already, like database servers, web servers, ... 

[1] https://docs.docker.com/engine/installation/linux/ubuntu/#install-using-the-repository

[2] https://hub.docker.com/

## Question: Docker and Docker Hub

Now that you are familiar with the basics of Docker:

- What are the differences between a Dockerfile and a Docker image? Can you imagine pros/cons?

- How does a typical workflow for deploying a new application component look like?

Have a look at the Docker Hub [1]. 

- Do you think it was useful to create an image for Apache by ourselves?

- How are images in Docker Hub created and maintained?

[1] https://hub.docker.com/