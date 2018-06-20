# Lesson 2: Container Orchestration with Rancher

Docker Swarm offers clustering of hosts to one large container cluster, and
orchestrates services by placing containers on available hosts. Rancher is very equal, yet it even offers a web ui to manage a Rancher container cluster.

## Research: Rancher

What is Rancher? Become familiar with the tool before we start.

http://rancher.com/

http://docs.rancher.com/rancher/v1.6/en/

## Question: Rancher

Where in our Cloud Stack do you place Rancher?

  | Cloud Stack | Example | Deployment Tool |
  | --- | --- | --- |
  | **Application Component** | Mediawiki | ? |
  | **Containers** | Docker | ? |
  | **Virtual Resource** | Instance m1.small | ? |
  | **Cloud Platform** | OpenStack | - |

## Task: Install and start Rancher

Connect via ssh to your rancher-master VM. Now start a Rancher service (it takes
several seconds until rancher is accessible):

```
docker run -d --restart=unless-stopped -p 8080:8080 --name rancher \
  rancher/server:stable
```

Note: if you get `docker: Got permission denied while trying to connect to the Docker daemon socket` the cloud-init script has not yet finished. Logout and login a few seconds later again.

Next, we will add hosts (virtual machines with a Rancher agent) to Rancher. Open
the web dashboard of your Rancher Master http://PUBLIC_IP:8080/.

 - Click on "Infrastructure > Hosts" and select "Add Host".
 - In "Host Registration URL" select "something else" and type in http://PRIVATE_IP:8080 with the private ip of your rancher-master. Press Save.
 - On the next site, copy the `sudo docker ...` command from step 5 and execute it on all your rancher-host VMs and also to your rancher-master.
 - Click "Close" and wait for the hosts to show up in the rancher dashboard.

Starting the rancher hosts will take some time. You can follow the process:
Rancher agents will be started, and several predefined containers like
healthchecker, or scheduler will be installed. When the hosts are up, you can
browse through the utilisation metrics and the deployed containers in the web
dashboard. When selecting single containers, you get get statistics about this
container only, its even possible to get execution shells into containers from
the dashboard.

Finally install the Rancher CLI tool inside your initial rancher VM:

```
wget -O rancher.tar.gz \
 https://github.com/rancher/cli/releases/download/v0.6.1/rancher-linux-amd64-v0.6.1.tar.gz
tar xfzv rancher.tar.gz
sudo mv rancher-v0.6.1/rancher /usr/bin/
sudo chmod +x /usr/bin/rancher
```

Besides the web dashboard you can now connect to rancher via CLI.

To authenticate in the CLI, you need an API Key. In the web dashboard, go to 
`API > Keys` and press the `Add Account API Key` Button. Enter any name and press create. You will get an Access Key and a Secret Key. Copy both to a place where you will find them later.

To use the CLI, run `rancher config` and provide `URL []:  http://134.60.64.XYZ:8080/v1`, the Access Key and Secret Key from before.
Validate that the login works with `rancher ps`.

## Task: Start Mediawiki via Rancher

Copy and unzip the dockerfiles.zip from exercise 4 to the rancher vm. Inside the extracted dockerfiles folder, create a docker-compose.yml with the following content:

```
version: '2'
services:
    web:
        build: Mediawiki
        image: omistack-vmXYZ.e-technik.uni-ulm.de:5000/mediawiki
        ports:
          - 80:80
    database:
        build: Database
        image: omistack-vmXYZ.e-technik.uni-ulm.de:5000/database
```

Then build and push the images to your registry:

```
docker-compose build
docker push omistack-vmXYZ.e-technik.uni-ulm.de:5000/database
docker push omistack-vmXYZ.e-technik.uni-ulm.de:5000/mediawiki
```

Now we are ready to import the docker-compose file as a `stack` into Rancher, either by web dashboard or by cli.

In the web dashboard, go to "Stacks", and press the "Add Stack" button. Add as name "mediawiki" and place as content of docker-compose.yml:

```
version: '2'
services:
    web:
        image: omistack-vmXYZ.e-technik.uni-ulm.de:5000/mediawiki
        ports:
          - 80:80
    database:
        image: omistack-vmXYZ.e-technik.uni-ulm.de:5000/database
```

Mediawiki will be started. Try to access it. You will recognize, that it is only accessible via the floating ip of the host where the web container is running. 

To allow any of the rancher hosts, we have to add a load balancer: 
In the mediawiki stack, click "add service" and select "load balancer".
Scale: Always run one instance of this container on every host
Name: wiki-loadblancer
Request Port 80, Target: web Port 80.

When selecting the web service, you can configure the Health Check, so rancher will restart failed containers automatically e.g. when the web server is not responding (Docker will only react on stopped containers). When you edit a service, you can scale it up and down. The loadbalancer will be configured automatically.
