# Lesson 3: Horizontal Scaling and Load Balancing

In this lesson, we create a second vm with mediawiki, another vm with nginx as a loadbalancer,
and we will extract the database into a separate vm. 

## Task: Create a second mediawiki vm
Create a new mediawiki vm, named "second_server" by using your snapshot from the previous exercise. 
This new VM must be attached to your private-net network! Make sure to use the same flavor as for main_server.
Since the IP of the monitoring VM is unchanged, your new second_server should appear in the Chronograf dashboard automatically.
Validate if the new vm shows up in Chronograf before you continue.

## Task: Create the loadbalancer
1. Create a new VM named "loadbalancer" with flavor "m1.nano" and image "ubuntu 16.04". This new VM must be attached to your private-net network!
2. Add a Floating IP to the loadbalancer vm, by clicking "Associate floating ip". If "no floating IPs are allocated"  is shown, click the "+" Button to allocate a floating IP from the "routed" pool.
3. Connect to the new loadbalancer vm via SSH

The loadbalancer vm is now accessible via floating ip from the public. But the vm is attached to the private network. OpenStack is taking care of the translation of floating ip to the ip of the vm in the private network. The vm itself is unaware of the floating ip (check the interfaces via `ip addr show`).

You can use this loadbalancer vm to access the two mediawiki servers via ssh hopping. You need to tunnel through the loadbalancer vm, e.g. via
`ssh -o ProxyCommand='ssh ubuntu@FLOATING_IP nc PRIVATE_IP_TO_ACCESS 22' ubuntu@PRIVATE_IP_TO_ACCESS` or via ssh config and the ProxyCommand setting.

Lets install the loadbalancer VM with nginx (copied from the nginx website):

```
sudo -s
nginx=stable
add-apt-repository ppa:nginx/$nginx
apt-get update
apt-get install nginx
```

Now that the nginx is installed, we need to configure it:

1. create a new config file /etc/nginx/conf.d/wiki.conf for nginx and open it with your favourite editor (nano, vim, emacs, ...).
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

Finally remove the default nginx site (rm /etc/nginx/sites-enabled/default) apply the configuration by restarting the nginx: `sudo service nginx restart`
Validate that the loadbalancer is working. Go to http://FLOATING_IP_OF_LOADBALANCER:80/ - you should see a apache default page.

Unfortunately, the mediawiki needs to be reconfigured, since the public IP of it is now the floating IP of the load balancer. 
Log in to both mediawiki vms and edit the file `/var/www/html/wiki/LocalSettings.php` and change the line `$wgServer = "http://134.60.x.y";` 
to fit your loadbalancer's floating ip.
The mediawiki is now accessible through http://FLOATING_IP_OF_LOADBALANCER:80/wiki

Now that we have a load balancer and two mediawiki instances running, think about the locality of your data store. Do the following tests:

 - Create a new page or edit an existing page. Store your changes
 - Reload the wiki and look for your changes. Are they still there? Reload and check several times if needed.
 - The changes are sometimes there, sometimes are missing. Why is this the case?

The random behaviour experienced is caused by the fact that both wiki instances store their data independently.
We will have to replace the individual mariadb databases by a commonly used mariadb database on an own virtual machine.

## Task: Extract database into separate vm
Set-up a new virtual machine named "database" from an ubuntu 16.04 image. Configure key, network, and the like just as before.
In addition, add a security rule that allows access to the mariadb port (3306). 
You may want to add a floating IP to access the new vm directly, or you can use the load balancer vm and ssh hopping.

Inside the new "database" vm, run the following commands:

```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install mariadb-server
```

Before we can export the database from your existing mediawiki vm and import it to the new one, don't forget to add the wikimedia user, database and permissions.
For a step-by-step guide, please have a look at exercise 1.

Per default, mariadb is configured to listen only to connections from the local host. This has to be changed, as multiple
wikimedia instances will access the database over the network. 
Use your favourite editor to open file /etc/mysql/my.cnf as sudo and change the bind address:

```
bind-address = '<database vm private ip>'
```

To apply the change in the configuration file, restart mariadb with `sudo service mysql restart`.

Ensure that it is possible to connect to the database over the network with your new user. From one of the mediawiki VMs, try the following:
`mysql -u wikiuser -h <database vm private IP> -p`

As the database is currently empty, we have to import the old database:

 - dump the database from *one* of the wiki VMs with `mysqldump -u wikiuser -p --databases wikidb > dump.sql`
 - copy the dump.sql file as discussed in one of the earlier lessons, e.g. scp, sftp to the new database vm
 - Import database on the new database vm with `mysql -u wikiuser -p < dump.sql`

Next, we have to tell both mediawiki instances to use the new database vm. For *both* vms, change
the file `/var/www/html/wiki/LocalSettings.php` to fit the following configuration parameters:

```
$wgDBtype = "mysql";
$wgDBserver = <internal ip of database vm>;
$wgDBname = "wikidb";
$wgDBuser = "wikiuser";
$wgDBpassword = "password";
```

## Task: Validate the scaled mediawiki application

Use the load balancer to access your mediawiki application. Make changes to some sites of your mediawiki to validate if the
consistency is still a problem. Run the stress test from the last exercise 2. 

As a bonus you can install telegraf on the new database vm and the new load balancer vm. Telegraf has also support for nginx,
to get monitoring data from your load balancer.

## Question: Stressing the horizontally scaled mediawiki

- How much requests per second have you achieved with the vertically scaled mediawiki setup?
- How much requests per second do you achieve now with the horizontally scaled mediawiki setup?
- Vertical scaling was quite limited to the maximum flavor size. Can you image the new bottleneck of horizontal scaling?

