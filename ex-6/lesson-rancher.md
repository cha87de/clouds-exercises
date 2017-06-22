# Lesson 2: Container Orchestration with Rancher

Docker Swarm offers clustering of hosts to one large container cluster, and orchestrates services by placing
containers on available hosts. Rancher is one level above: it offers a web gui to 

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

In bwcloud create a new keypair via `Access&Security > Key Pairs > Create Key Pair` with name rancher. 
Next, use the terraform scripts in `terraform-rancher` to start a new virtual machine with docker and a docker
registry. When the VM is up, place your Keypair rancher.pem file inside the vm at /opt/keypair/.

Now start a Rancher service (it takes several seconds until rancher is accessible):

```
docker run -d --restart=unless-stopped -p 8080:8080 --name rancher \
  -v /opt/keypair:/opt/keypair \
  rancher/server:stable
```

Next, we will add hosts (virtual machines with a Rancher agent) to Rancher, while Rancher will create the 
virtual resources.
Open the web dashboard of your Rancher server http://PUBLIC_IP:8080/ and run the following instructions:

* Admin > Machine Drivers
* Activate OpenStack by pressing play button

* Infrastructure > Hosts
* Press "Add Host" Button
* Select "Other" and in the form insert the following values:

  | Field | Value |
  | --- | --- |
  | Name              | rancher-hosts                  |
  | Quantity          | 3                  |
  | Driver            | openstack                  |
  |                   |                   |
  | authUrl           | https://bwcloud.ruf.uni-freiburg.de:5000/v2.0                  |
  | availabilityZone  | nova                  |
  | flavorName        | m1.small                  |
  | floatingipPool    | routed                  |
  | imageName:        |	Ubuntu Server 16.04 RAW                  |
  | keypairName:      | rancher                  |
  | netName:          | private-net                  |
  | password:         | YOUR_BWCLOUD_PW                  |
  | privateKeyFile:   | /opt/keypair/rancher.pem                  |
  | region:           | Ulm                  |
  | secGroups:        | default,rancher       |
  | sshUser:          | ubuntu                  |
  | tenantName:       | Projekt_ehx27@uni-ulm.de                  |
  | username:         | ehx27@uni-ulm.de                  |

* Press the Create button and wait for the virtual machines to be spawned...

Starting the rancher hosts will take some time. You can follow the process: the virtual machines will be created, Docker will be installed, Rancher agents will be installed, and several predefined containers like healthchecker, or scheduler will be started. When the hosts are up, you can browse through the utilisation metrics and the deployed containers in the web dashboard. When selecting single containers, you get 
get statistics about this container only, its even possible to get execution shells into containers from the dashboard.

Finally install the Rancher CLI tool inside the rancher VM:

```
wget -O rancher.tar.gz \
 https://github.com/rancher/cli/releases/download/v0.6.1/rancher-linux-amd64-v0.6.1.tar.gz
tar xfzv rancher.tar.gz
sudo mv rancher-v0.6.1/rancher /usr/bin/
sudo chmod +x /usr/bin/rancher
```

Besides the web dashboard you can now connect to rancher via CLI.

To authenticate in the CLI, you need an API Key. In the web dashboard, to to 
`API > Keys` and press the `Add Account API Key` Button. Enter any name and press create. You will get an Access Key and a Secret Key. Copy both to a place where you will find them later.

To use the CLI, run `rancher config` and provide `URL []:  http://134.60.47.XYZ:8080/v1`, the Access Key and Secret Key from before.
Validate that the login works with `rancher ps`.

## Task: Start Mediawiki via Rancher

Copy and unzip the dockerfiles.zip from exercise 4 to the rancher vm. Inside the extracted dockerfiles folder, create a docker-compose.yml with the following content:

```
version: '2'
services:
    web:
        build: Mediawiki
        image: bwcloud-fipXYZ.rz.uni-ulm.de:5000/mediawiki
        ports:
          - 80:80
    database:
        build: Database
        image: bwcloud-fipXYZ.rz.uni-ulm.de:5000/database
```

Then build and push the images to your registry:

```
docker-compose build
docker push bwcloud-fipXYZ.rz.uni-ulm.de:5000/database
docker push bwcloud-fipXYZ.rz.uni-ulm.de:5000/mediawiki
```

Now we are ready to import the docker-compose file as a `stack` into Rancher, either by web dashboard or by cli.

In the web dashboard, go to "Stacks", and press the "Add Stack" button. Add as name "mediawiki" and place as content of docker-compose.yml:

```
version: '2'
services:
    web:
        image: bwcloud-fipXYZ.rz.uni-ulm.de:5000/mediawiki
        ports:
          - 80:80
    database:
        image: bwcloud-fipXYZ.rz.uni-ulm.de:5000/database
```

Mediawiki will be started. Try to access it. You will recognize, that it is only accessible via the floating ip of the host where the web container is running. 

To allow any of the rancher hosts, we have to add a load balancer: 
In the mediawiki stack, click "add service" and select "load balancer".
Scale: Always run one instance of this container on every host
Name: wiki-loadblancer
Request Port 80, Target: web Port 80.

When selecting the web service, you can configure the Health Check, so rancher will restart failed containers automatically e.g. when the web server is not responding (Docker will only react on stopped containers). When you edit a service, you can scale it up and down. The loadbalancer will be configured automatically.
