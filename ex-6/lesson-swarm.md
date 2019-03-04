# Lesson 1: Container Orchestration with Docker Swarm

In this lesson, we will install and use Docker Swarm, as the built in Docker orchestrator across multiple hosts.

## Research: How Docker Swarm works

Make yourself familiar with Docker Swarm. The two links should give you enough information to work with Swarm in the following:

https://docs.docker.com/engine/swarm/how-swarm-mode-works/nodes/

https://docs.docker.com/engine/swarm/how-swarm-mode-works/services/


## Questions: Docker Swarm

* In the Swarm terminology, what are services, tasks, and containers?

* Where in our Cloud Stack do you place Docker Swarm?

| Cloud Stack | Example | Deployment Tool |
| ---- | ---- | ---- |
| **Application Component** | Mediawiki | ? |
| **Containers** | Docker | ? |
| **Virtual Resource** | Instance m1.small | ? |
| **Cloud Platform** | OpenStack | - |

## Task: Setup Docker Swarm

Deploy three virtual machines with docker installed on OpenStack. We can use the terraform bundle "terraform-dockernodes.zip" to automatise this process. Update the `provider.tf` as we did in exercise 4.

Log in to the three VMs via SSH. Validate that Docker is running (e.g. via `docker ps -a`).
Docker Swarm is inactive, validate output of `docker info` and search for line `Swarm: inactive`.

Note: if you get `docker: Got permission denied while trying to connect to the Docker daemon socket` the cloud-init script has not yet finished. Logout and login a few seconds later again.

Lets take dockernode1 as swarm manager. Log in to dockernode1, look up the private IP address of this VM (`$PRIV_IP_DOCKERNODE1`), then run `docker swarm init --advertise-addr $PRIV_IP_DOCKERNODE1`.
The output of this command returns:

```
Swarm initialized: current node (....) is now a manager.

To add a worker to this swarm, run the following command:

  docker swarm join \
  --token SWMTKN-1..... \
  192.168.5.4:2377
```

Copy/Paste the `docker swarm join` command to dockernode2 and dockernode3.
Validate your Docker Swarm cluster on dockernode1 with `docker node ls` - you should see three hosts.

## Task: Start a test service

For testing purposes we will now start three instances of the Ghost blog software on our Swarm cluster. Note: `docker service ...` commands can only be executed on the swarm manager, in our case dockernode1. Create the service with 3 replicas:

```
docker service create --replicas 3 --name ghost-blog\
  --publish 80:2368 ghost
```

Validate that the service is booting with `docker service ls`, where the counter in column "REPLICAS" will go from 0/3 to 3/3 eventually.
You can see that the three replicas are distributed among the three nodes: `docker service ps ghost-blog`.
On each virtual machine run `docker ps`, you will have one container of the ghost service on each node.
Take a browser, and go to any of your three floating IPs on port 80 to access the ghost instances.

Swarm allows you to scale horizontally up and down (`docker service scale $SERVICE_NAME=$NUMBER_OF_REPLICAS`). You can easily scale down the ghost service to only one replica with `docker service scale ghost-blog=1`. Validate the number of replicas with `docker service ps ghost-blog`. Note: if your container runs on e.g. dockernode1 you can access the ghost blog via http://$FLOATING_IP_DOCKERNODE1/. But Swarm handles published ports across all swarm nodes. You can also access the ghost blog via any other floating ip.

Updating the software is also handled by Swarm, where sequentially containers are removed and recreated to achieve zero downtime of the service. In case of errors, Swarm can rollback to the previous version.

Remove the test service with `docker service rm ghost-blog` before you continue.

## Task: Mediawiki with Docker Swarm

Docker Swarm and Docker Compose work together (software is experimental at present).

So far we built the images from Dockerfiles on the node where we started containers from those images. Since we're having a 
distributed Swarm cluster, we need a central store for our built images: a (private) docker registry. 
We could use Docker Hub, or deploy our own registry. On dockernode1, run the following commands to run your own docker registry:

```
# install certbot to get certificate
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y --allow-unauthenticated certbot 

# lookup your public hostname
floatingIP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
publicHostname=$(nslookup $floatingIP | grep "in-addr.arpa" |\
   cut -d'=' -f2 | tr -d ' ''')

# get certificate
sudo certbot certonly --standalone -d $publicHostname --agree-tos \
  --register-unsafely-without-email --preferred-challenges http
sudo mkdir /opt/certs
folder=$(sudo ls /etc/letsencrypt/live/)
sudo cp /etc/letsencrypt/live/$folder/fullchain.pem /opt/certs/
sudo cp /etc/letsencrypt/live/$folder/privkey.pem /opt/certs/

# finally: start your docker registry as container 
docker run -d -p 5000:5000 --restart=always --name registry \
  -v /opt/certs:/certs \
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/fullchain.pem \
  -e REGISTRY_HTTP_TLS_KEY=/certs/privkey.pem \
  registry:2
```

Next, copy the Dockerfiles from exercise 5 to dockernode1.
Change the `docker-compose.yml` file to the following content
(replace `omistack-vmXYZ.e-technik.uni-ulm.de` to fit your `$publicHostname`!):

```
version: '3'
services:
    web:
        build: Mediawiki
        image: omistack-vmXYZ.e-technik.uni-ulm.de:5000/mediawiki
        ports:
          - 80:80
        deploy:
          replicas: 2
          mode: replicated
    database:
        build: Database
        image: omistack-vmXYZ.e-technik.uni-ulm.de:5000/database
        deploy:
          replicas: 1
          mode: replicated
```

Then build and push the images to your registry (still on dockernode1):

```
docker-compose build
docker push omistack-vmXYZ.e-technik.uni-ulm.de:5000/database
docker push omistack-vmXYZ.e-technik.uni-ulm.de:5000/mediawiki
```

Validate, that the registry works. Go to dockernode2 and download the image via `docker pull omistack-vmXYZ.e-technik.uni-ulm.de:5000/database`

Now we can use Docker Swarm to deploy our Docker Compose file. On dockernode1, run:

```
docker stack deploy --compose-file docker-compose.yaml mediawiki
```

Validate with `docker stack ps mediawiki` that you have three containers
running, and check if you can access the mediawiki application via web browser. 

We have now deployed the mediawiki in Docker containers across several (manually
created) Docker hosts.

## Task: Clean up

Depending on your interests, run experiments with Docker Swarm. When you're done, make sure to clean up the resources in OpenStack, especially before moving on to the next lesson. 

Clean up with terraform is as easy as typing `terraform destroy` :-)