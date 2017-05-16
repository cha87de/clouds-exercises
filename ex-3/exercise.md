# Exercise 3: Scaling and Load Balancing

In this section we will extend the wiki application by a load balancer and horizontal scaling capabilities. For that purpose, we add another virtual machine.

For this and the following two lessons, it is assumed that you have a working wiki installation. This was subject to the Hands-on OpenStack section.

# Part 1: Virtual Networks & Floating IPs

## Question: Virtual Networks & Floating IPs
OpenStack offers a virtual infrastructure, including virtual networks. Before we continue with the scaling of the mediawiki application, let's switch from plain public IPs to a virtual private network and public floating IPs.

Before we start, what is a floating IP? What advantages and disadvantages do you see when using floating IPs?

## Task: Create a private network in OpenStack

Go to "Network -> Networks".

Click "Create Network".

Define the following settings:

Network
Network name: "private-net"
Admin State: "Up"
Create Subnet: Checked
Subnet 
Subnet Name: "private-subnet"
Network Adress: "192.168.5.0/24"
IP Version: IPv4
Gateway IP: <empty>
Disable Gateway: unchecked
Subnet Details
Enable DHCP: Checked
Everything else: <empty> 

## Task: Create Router

The private network can now be used, virtual machines will get IP addresses automatically via DHCP. Yet, there is no connection to the public internet so far. Therefore we need a virtual router, which connects the private virtual network with the public network.

Go to "Network -> Routers".

Click Create Router.

Define the following settings:

Name: "my-router"
External Gateway: "routed"
Go to tab "Interface" of this router.

Click "Add interface".

Define the following settings:

Subnet: "private-subnet"
Everything else is default
 From now on you should be able to create VMs in the network "private-net". These VMs will get a private IP address via DHCP. To access these VMs from the public internet, you can assign a floating IP to VMs which need public access. Not all VMs necessarily need to be accessible publicly (e.g. a database server). To still have a SSH connection you can do ssh hopping: log in to a VM with floating IP and from there tunnel through the VM you want to access. For more details, check the man pages of ssh [1] and search for ProxyCommand.

[1] https://linux.die.net/man/5/ssh_config

## Task: Move main_server to private network
We will now attach the existing virtual machine named main_server with the mediawiki application to the new private network. Therefore, walk through the following steps in the bw-cloud openstack dashboard:

In the menu list of the main_server instance, select "attach interface"
Select "private-net" and press "attach interface" button
Verify, that your instance now has two interfaces (the existing one in network "public" and the new one in "private-net")
In the menu list of the main_server instance, select "detach interface"
Select the address from the public network, and press the button to continue.
Verify, that your instance now has only one interface with a private IP address (192.168.5.x)
"Soft Reboot" the instance via the openstack dashboard to make sure it sets the IP routing correctly.
The virtual machine is now not accessible any more from the outside. In the next step we will create a new vm with floating IP, from which you can tunnel through to your private network.

# Part 2: Horizontal Scaling

In this lesson, we create a second VM with media wiki and we prepare another virtual machine that runs nginx as a loadbalancer, that balances the load between the two media wiki VMs.

## Task: Create two more virtual machines
1. Create new mediawiki VM, named "second_server" by using your snapshot. This new VM must be attached to your private-net network! Since the IP of the monitoring VM is unchanged, your new second_server should appear in the Chronograf dashboard automatically.
2. Create a new VM named "loadbalancer" with flavor "m1.nano"  and image "ubuntu 16.04". This new VM must be attached to your private-net network!
3. Add a Floating IP to the loadbalancer vm, by clicking "Associate floating ip". If "no floating IPs are allocated"  is shown, click the "+" Button to allocate a floating IP from the "routed" pool.
4. Connect to the new loadbalancer VM 

The loadbalancer vm is now accessible via floating ip from the public. But the vm is attached to the private network. OpenStack is taking care of the translation of floating ip to the ip of the vm in the private network.

You can use this loadbalancer vm to access the two mediawiki servers via ssh. You need to tunnel through the loadbalancer vm, e.g. via
ssh -o ProxyCommand='ssh ubuntu@FLOATING_IP nc PRIVATE_IP_TO_ACCESS 22' ubuntu@PRIVATE_IP_TO_ACCESS
Or via ssh config ProxyCommand.

## Task: Install loadbalancer and fix mediawiki
Lets first install the loadbalancer. Log in to the loadbalancer vm and execute the install script for nginx (copied from the nginx website):

```
sudo -s
nginx=stable
add-apt-repository ppa:nginx/$nginx
apt-get update
apt-get install nginx
```

Now that the nginx is installed, we need to configure it

1. create a new config file /etc/nginx/conf.d/wiki.conf for nginx and open it with e.g. vim
2. Copy and paste the following content into this file (replace the two IP addresses with the ones from your main_server and second_server):
```
  upstream myproject {
    server YOUR_MAIN_SERVER_IP:80;
    server YOUR_SECOND_SERVER_IP:80;
  }
  server {
    listen 80;
    location / {
      proxy_pass http://myproject;
    }
  }
```  
Finally remove the default nginx site (rm /etc/nginx/sites-enabled/default) apply the configuration by restarting the nginx: sudo service nginx restart
Validate that the loadbalancer is working. Go to http://FLOATING_IP_OF_LOADBALANCER:80/ - you should see a apache default page.

Unfortunately, the mediawiki needs to be reconfigured, since the public IP of it is now the floating IP of the load balancer. Log in to both mediawiki vms and edit the file /var/www/html/wiki/LocalSettings.php and change $wgServer = "http://134.60.x.y"; to your loadbalancer's floating ip.
The mediawiki is now accessible through http://FLOATING_IP_OF_LOADBALANCER:80/wiki

## Task: Consistency issues..
Now that we have a load balancer and two mediawiki instances running, think about the locality of your data store. Do the following tests:

Create a new page or edit an existing page. Store your changes
Reload the wiki and look for your changes. Are they still there? Reload and check several times if needed.
The changes are sometimes there, sometimes are missing. Why is this the case?

# Part 3: Ensure Consistency
The random behaviour experienced at the end of the last lesson is caused by the fact that both wiki instances store their data independently. In this lesson we will replace the individual mariadb databases by a commonly used mariadb database on an own virtual machine.

## Task: Prepare Database VM
In the following, we will work on a new virtual machine . For that reason, set-up a new virtual machine from an ubuntu 14.04 image. Configure key, network, and the like just as before and assign a new floating IP to it just list like. In addition, add a security rule that allows access to the mariadb port (3306). 

Finally, connect to the virtual machine and install mariadb by executing

sudo apt-get install mariadb-server



note: it may be beneficial or even required to first run the following commands in order to refresh the installation paths.

sudo apt-get update

sudo apt-get upgrade

## Task: Set-up Database
On your database virtual machine, log in to the database by executing sudo mysql -u root -p. You are now connected to the postgres command line. In order to be able to use the database system for wikimedia, we have to create a new database and a user that is allowed to access that database. Search the Internet for how to

- create a new database; call this database wikidb
- create a new user wikiuser; ensure to set a password for that user
- assign this user the the necessary privileges to access the database

Post your solution.

## Task: Set-up Database (ii)

Here is a solution to the previous question in case you were not able to find the correct answer. Log in to the mysql shell ( sudo mysql -uroot -p) and perform the following operations:

create database:  CREATE DATABASE wikidb;

create user that can access from remote:  

GRANT ALL PRIVILEGES ON wikidb.* TO 'wikiuser'@'%' IDENTIFIED BY 'abcdefg';

## Task: Configure Database

Per default, wikidb is configured to listen only to connections from the local host. This has to be changed, as multiple wiki instances will access the database over the network. In particular, we have to make postgres listen on the network and also to enable access from the outside world.

change bind address:

use your favourite editor to open file /etc/mysql/my.cnf as sudo and change the bind address

bind-address = '<database vm private ip>'

change access rights of user:

We have to allow to login as wikiuser from the outside world.

Connect to mysql:

mysql -u wikiuser -p

Execute the command:

GRANT ALL PRIVILEGES ON wikidb.* TO 'wikiuser'@'%' IDENTIFIED BY 'abcdefg'; 

restart mariadb:

sudo service mysql restart

ensure that it is possible to connect to the database over the network with your new user:

 mysql -u wikiuser -h <database vm private IP> -p

As the database is currently empty, we have to import the old database.

dump database from one of the wiki VMs: mysqldump -u wikiuser -p --databases wikidb > dump.sql

copy the dump.sql file as discussed in one of the earlier lessons, e.g. scp, sftp…

Import database on the new database VM: mysql -u wikiuser -p < dump.sql

## Task: Configure MediaWiki for remote MariaDB
so far, we have: 
- one load balancer dispatching requests between
- two wiki instances and
- a single database

What is currently missing is that the wiki instances make actually use of the database. So this step will be used to configure MediaWiki for mariadb.

Search the Internet on how to change the configuration file for MediaWiki in order to connect to the remote DB. Post your configuration.

## Task: Configure MediaWiki for remote MariaDB (ii)
This is the solution to the previous question.

Replace the following block 

```
$wgDBtype = "mysql";
$wgDBserver = "localhost";
$wgDBname = "wikidb";
$wgDBuser = "wikiuser";
$wgDBpassword = "password";
```

with this one:
```
$wgDBtype = "mysql";
$wgDBserver = <internal ip of database vm>;
$wgDBname = "wikidb";
$wgDBuser = "wikiuser";
$wgDBpassword = "password";
```
Once, you saved the file, complete the configuration as follows:

repeat the same steps for the wiki configuration of the first server 

## Task: Verify Load Balancing
We are almost done.

Verify that the blog is available under the DNS name of your public IP address. Note that due to the changed database all entries are purged and also your user account has been deleted.
Verify that you can create a new user account.
Verify that you can create new blog entries
Discuss how you would test that the load balancing actually works. 

## Task: Release unused floating IPs 

You now have set up a total of three virtual machines:

VM1 runs nginx
VM2 runs mediawiki
VM3 runs mediawiki
VM4 runs mariadb
of which only nginx needs to be accessed from the public. In order to secure your system and not drain all our public IPs, release the floating IPs of the other virtual machines.

# Part 4: Bonus Questions

## Question: 
Now we have a fairly useful set-up of a wiki. If you want to play more with the current configuration, you can investigate more on the following aspects:

Figure out how you can stress your blog and monitor the load on your system
Figure out how you can scale your sql dabase. You may want to start off with googling for mariadb cluster
