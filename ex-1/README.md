---
mainfont: Open Sans
mainfontoptions: BoldFont=Open Sans Bold
mainfontoptions: ItalicFont=Open Sans Italic
mainfontoptions: BoldItalicFont=Open Sans Bold Italic
---
# Exercise 1: OpenStack
In this section we will install a wiki application on an OpenStack instance. 

# Part 1: Virtual Machine Preparation Lektion

## Question: Virtual Machines
While we will discuss the concept of virtualisation and virtual machines in-depth in the lectures, we require some information prior to the hands-on session. For that reason it is necessary that you get some basic understanding of virtual machines. 

Please research the web for some definitions. Reading the [wikipedia page](https://en.wikipedia.org/wiki/Virtual_machine) is sufficient for the start. You will get more knowledge in the course of the lecture. Summarise what you learned in some sentences.

## Task: Access to OpenStack
Throughout this lesson, we will use an OpenStack instance hosted by the universities of Baden-Wuerttemberg (bw-cloud.org) In order to get access to this instance, you have to request an account. More information on how to request an account can be found on the website http://www.bw-cloud.org/en/first_steps/index or in the accompanying slide set. Please note, that why we try to process the request as quickly as possible  you should give us some time to do so (half a day during the week).

Once you have access to the bw-cloud, you can access it under https://bwcloud.ruf.uni-freiburg.de/dashboard/auth/login/?next=/dashboard/.

The bw-cloud website also holds valuable information on how to use the service, describing how to start virtual machines and how to access them (http://www.bw-cloud.org/en/usage/index).

## Task: Create Key
In order to run software, this has to be installed first; prior to installing software, you need to get a Virtual Machine running. In order to be able to access the Virtual Machine later on, it is necessary to create an access key. Hence, click "Access & Security" on the left column and then select "Key Pairs". Finally, click "Create Key Pair". Pick a random name. In the following, we will assume that the key is called "cloud_key".

OpenStack will immediately download the private key as a file after it has created the Key Pair. It is important that you save and keep this file, as you will need it later on and there is no actual way make OpenStack deliver it again.

## Task: Adapt Security Rules 
Adapt Security Rules Seite verschieben: Adapt Security Rules Seite aktualisieren: Adapt Security Rules Seite anzeigen: Adapt Security Rules Seite löschen: Adapt Security Rules
By default, the security rule with OpenStack blocks all incoming network traffic. In order to be later able to ping and access your virtual machine, we need to unblock the network. In order to do that, go to the "Access & Security" and edit your "default" group such that you allow incoming (ingress) traffic for:

1. ICPM (used by the IP protocol) from everywhere (CIDR 0.0.0.0/0)
2. TCP port 22 (used by ssh) from everywhere (CIDR 0.0.0.0/0)
3. TCP port 80 (used by the webserver) from everywhere (CIDR 0.0.0.0/0)

More background information is available [here](https://community.hpcloud.com/article/managing-your-security-groups-0).

## Task: Launch instance

Now, we will start a Virtual Machine by launching what OpenStack calls an instance.

1. Select "Instances" on the left column and click "launch instance".
2. Select "nova" as availability zone and pick an arbitrary instance name; in the following we assume that this instance will be called "main_server".
3. Select "m1.small" as flavor and leave "1" as instance count (note, you are allowed to create more that one instance and also to use other flavors; however, there is a quota on your account so that you may not be able to create further virtual machines at later stages of this exercise; neither are the following steps guaranteed to work correctly).
4. Select "Boot from image" in "Instance Boot Source" and select the Ubuntu 14.04 Operating System (note, you may also select other linux operating systems, but the rest of the tutorial will describe the steps required for ubuntu).
5. On the "Access & Security" tab, select "cloud_key" as your key and use "default" as security group.
6. On the networking tab the public network should be the only available network and should be automatically selected. If this is not the case drag & drop the only available network to "Selected Networks".
7. Finally, launch the virtual machine.

Launching may take a while, but should result in a status of "Active".

## Question: Accessing Virtual Machine 
Looking at the information you get about the running virtual machine from OpenStack, can you guess what further steps are necessary to access this virtual machine?

# Part 2: Virtual Machine Access

## Question: Internal IP address 
What is/are the IP address(es) assigned to your Virtual Machine?

## Task: Make use of SSH keys
It is time to log-in. This can be done using the SSH protocol via an SSH client. Here, the right approach depends on what operating system you use, Windows or Linux.

In both cases it is required to have a local copy of the private OpenStack key available (cloud_key.pem) that you stored in an earlier step of this exercise. 

The correct username for the ubuntu image is ubuntu.

* Windows:
For Windows users, we suggest using [putty in combination with puttygen](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html). An instruction on how to make use of the OpenStack key with putty is available [here](https://github.com/naturalis/openstack-docs/wiki/Howto:-Creating-and-using-OpenStack-SSH-keypairs-on-Windows) in the sections "Converting a Key" and "Using the key with putty".

* Linux
In Linux an SSH client is shipped with almost all distributions. Using a key can be enforced by applying the -i command line parameter (for details see man ssh).

## Question: Other approach
Can you figure out of at least one other approach for accessing the console of your virtual machine?

# Part 3: Install Mediawiki Application

## Task: Install Mediawiki Application

As we are now able to access the shell of the virtual machine, we will install the mediawiki application in the next steps. The basic strategy and a good overview is given on [this page](https://www.mediawiki.org/wiki/Manual:Installation_guide/en). While there are multiple ways to install mediawiki, [this](https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki) and [this](https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Ubuntu) guide give the best overview. We follow both guides and execute the described steps. If you are not familiar with Linux, the Ubuntu OS or the shell, the unix_linux_tutorial.pdf offered on our course start site may prove helpful.

Before we can use the package system (apt-get) of Ubuntu, we should make sure everything is up-to-date.

1. sudo apt-get -y update && sudo apt-get -y dist-upgrade
2. sudo reboot

Afterwards the server will restart and you need to reconnect to it using ssh.

First, we need to install multiple dependencies required for running the mediawiki installation. As mediawiki is a php application we need a webserver serving the pages, the php5 runtime engine for executing the code and a database as storage backend. We execute the following steps:

1. Install the Apache Webserver - sudo apt-get install apache2
2. Install the mariaDB database. This installation will prompt for a password, enter one and remember it. - sudo apt-get install mariadb-server
3. Install php5 - sudo apt-get install php5 php5-mysql
4. Restart the apache server - sudo service apache2 restart

Now we can start to install the mediawiki application:

1. Make sure you are in your home directory - cd ~
2. Download latest version of mediawiki (currently 1.28.2) 
    ```
    wget https://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.2.tar.gz
    ```
3. Extract the tarball - tar -xvzf mediawiki-*.tar.gz
4. Switch to the httpdocs directory of apache2 - cd /var/www/html
5. Create a symbolic link to the httpdocs directory of apache2 - sudo ln -s ~/mediawiki-{version} wiki

You should now be able to see the initial page of mediawiki at http://{ip-of-your-vm}/wiki.

Please note:

- don't worry if the sudo command will print an unable to resolve host warning, we will address this later when fixing the server name of apache2
- you should not need to worry about the version number of mediawiki, choose the latest version found on the mediawiki page
- you cannot download the files from your browser as you want to install the application in a VM. Instead you have to download it from within the VM for instance by using the wget or curl tools. (Or you have to later copy them to the VM using scp)
- mariaDB is a fork of mysql. It offers the same client and SQL Syntax. So don't be confused if some of the later points mention mysql.
- don't worry if the restart command of the apache2 server outputs a warning (server name not found). Everything is fine and we will address this problem later on.

## Task: Setup Database
When accessing your wiki in the current state, you will be notified that you need to configure it first. For this purpose we first of all need to set up the database.

1. Connect to the database using the mysql command line client - mysql -u root -p

2. In the following prompt enter the password you created for the database in the installation step.

3. Create a new database for the wiki - CREATE DATABASE wikidb;

4. Create a new database user and grant him all privileges for the database, replace password by a password of your choice and remember it - GRANT ALL PRIVILEGES ON wikidb.* TO 'wikiuser'@'localhost' IDENTIFIED BY 'pasword'; 

5. Updated the privileges - flush privileges;

6. Exit the mysql client - exit

Notes:

every command within the mysql command line needs to end with a semicolon (;)
in the current state your database is only accessible from the virtual machine, thus you need to open the mysql command line while being connected to the VM

## Question: Server name
Figure out what is the DNS name associated with your server's IP. This can be retrieved via the nslookup tool (Linux) and Nslookup.exe (Windows). The basic usage is `nslookup $your_server_ip`.

## Question: Fix the server name of apache.
Fix the server name of apache. Seite verschieben: Fix the server name of apache. Seite aktualisieren: Fix the server name of apache. Seite anzeigen: Fix the server name of apache. Seite löschen: Fix the server name of apache.
After you have found out the servername of your server, you can fix an error you experienced when restarting the apache2 webservice when using the sudo service apache2 restart command.

AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1. Set the 'ServerName' directive globally to suppress this message.

Can you figure out why this error happens and how you can solve it?

(Hint: this step will not block you from the rest of the exercise)

## Task: Configure the mediawiki installation
The mediawiki installation can be configured using a user-friendly web-based installation wizard, that is available when clicking the setup the wiki link on your wiki page.

When the installation wizard asks you for the database setup change the database name to wikidb (remember, you created it earlier), the database user to wikiuser (you created it earlier) and the database password to the one you chose when creating the wikiuser.

When the installation wizard asks you for a name of the wiki and a username and password, enter your name for the wiki and chose a username and password you can remember.

In the options overview, uncheck the box 'Enable outbound mail'.

All other options can safely be ignored.

Finally, the wizard will install the wiki and you will automatically download a LocalSettings.php that needs to be copied into the wiki folder of the server.

For this task there are multiple solutions, depending on the system where you downloaded the LocalSettings.php:

(Unix) use scp to copy the file to your server 
(Windows) use the graphical https://winscp.net/eng/index.php to copy the file to our vm
(Both) use an editor like vim or nano to open and create a LocalSettings.php on your vm and then paste the content of the downloaded file.

## Question: Questioning the installation of mariaDB on the same server.
So far, we have installed the mariaDB server on the same server as the mediawiki installation and linked them using the localhost address.

Can you explain why this is good for performance in the current case, but may hinder the performance in the long run? 

What alternative approach do you suggest?

## Task: Create you first wikipage and link to it. 
Congratulations, you have successfully installed mediawiki. After copying the LocalSettings.php file to your server, you should be able to access the main page of your wiki installation.

On this page edit the main page and add a more welcoming description to your wiki. Afterwards copy a link to your wiki as answer to this question.

## Question: Review and scalability discussion
In the last exercises, we have deployed and configured a Web-based application (mediawiki) in the cloud. 

However, your mediawiki installation is currently running on only one host, which is hindering scalability and elasticity. This is definitely not good enough for a large installation as the WIkipedia Foundation uses it for the well-known Wikipedia. 

Can you find out what we need to do to cater for a larger, multi-node installation of mediawiki?

(Hint: the architecture overview https://www.mediawiki.org/wiki/Manual:MediaWiki_architecture may prove helpful)

# Part 4: Bonus questions

## Question: PHP
What are the main differences between PHP (the programming language used for mediawiki) and the Java programming language, especially with respect to type safety, object orientation and execution (interpretation/compilation)?

Can you think of a implications the differences may cause with respect to performance?

## Question: Other database
Can you get your installation of mediawiki running with another relational database, e.g. Postgres?

# Part 5: Backup your work

## Task: Create a snapshot
To backup the work you have done in the previous steps, and to be able to restore your virtual machine quickly, please create a snapshot of your virtual machine.

In the instances overview of the openstack dashboard, click the "Create Snapshot" Button in the drop-down menu on the right.

Openstack will automatically create a snapshot of the current state of your VM. This process may take some time...
