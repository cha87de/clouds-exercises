# Lesson 3: Install Mediawiki Application

## Task: Install Mediawiki Application

As we are now able to access the shell of the virtual machine, we will install
the mediawiki application in the next steps. The basic strategy and a good
overview is given on [this
page](https://www.mediawiki.org/wiki/Manual:Installation_guide/en). While there
are multiple ways to install mediawiki,
[this](https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki) and
[this](https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Ubuntu) guide
give the best overview. We follow both guides and execute the described steps.

Before we can use the package system (apt-get) of Ubuntu, we should make sure everything is up-to-date.

1. `sudo apt-get -y update && sudo apt-get -y dist-upgrade`
2. `sudo reboot`

Afterwards the server will restart and you need to reconnect to it using ssh.

First, we need to install multiple dependencies required for running the mediawiki installation. As mediawiki is a php application we need a webserver serving the pages, the php5 runtime engine for executing the code and a database as storage backend. We execute the following steps:

1. Install the Apache Webserver - `sudo apt-get install apache2`
2. Install the MariaDB database. - `sudo apt-get install mariadb-server`
3. Install php5 - `sudo apt-get install php php-mysql php-mbstring php-xml libapache2-mod-php`
4. Restart the apache server - `sudo systemctl restart apache2`

Now we can start to install the mediawiki application:

1. Make sure you are in your home directory:
    `cd ~`
2. Download latest version of mediawiki (currently 1.30.0):

    `wget https://releases.wikimedia.org/mediawiki/1.30/mediawiki-1.30.0.tar.gz`
3. Extract the tarball:
    `tar -xvzf mediawiki-*.tar.gz`
4. Switch to the http document root directory of apache2:
    `cd /var/www/html`
5. Create a symbolic link to the downloaded mediawiki software:
    `sudo ln -s ~/mediawiki-1.30.0 wiki`

You should now be able to see the initial page of mediawiki at http://{ip-of-your-vm}/wiki. If the Browser keeps loading and ends with a timeout, check again the Security Groups (is there a Port 80 as suggested in lesson 1?)

Please note:

- don't worry if the sudo command will print an "unable to resolve host warning"
- you should not need to worry about the version number of mediawiki, choose the latest version found on the mediawiki page
- you cannot download the files from your browser as you want to install the application in a VM. Instead you have to download it from within the VM for instance by using the wget or curl tools. (Or you have to later copy them to the VM using scp)
- MariaDB is a fork of MySQL. It offers the same client and SQL Syntax. So don't be confused if some of the later points mention mysql.
- don't worry if the restart command of the apache2 server outputs a warning (server name not found). Everything is fine and we will address this problem later on.

## Task: Setup Database

When accessing your wiki in the current state, you will be notified that you need to configure it first. For this purpose we first of all need to set up the database.

To secure your database, first run `sudo mysql_secure_installation`, accept all default suggestions, and define a root password (use it later in "PASSWORD_FROM_BEFORE").

1. Connect to the database using the mysql command line client:
    `sudo mysql`

2. Before we continue, we have to fix the root password:
    `UPDATE mysql.user SET password=password('PASSWORD_FROM_BEFORE') WHERE user='root'; UPDATE mysql.user SET plugin='' WHERE user='root';`

3. In the following prompt enter the password you created for the database in the installation step.

4. Create a new database for the wiki:
    `CREATE DATABASE wikidb;`

5. Create a new database user and grant him all privileges for the database, replace password by a password of your choice and remember it:
    ```
    GRANT ALL PRIVILEGES ON wikidb.* TO 'wikiuser'@'localhost' IDENTIFIED BY 'password';
    ```

6. Updated the privileges:
    `flush privileges;`

7. Exit the mysql client:
    `exit`

Notes:

every command within the mysql command line needs to end with a semicolon (;) in
the current state your database is only accessible from the virtual machine,
thus you need to open the mysql command line while being connected to the VM


## Task: Configure the mediawiki installation

The mediawiki installation can be configured using a web-based installation
wizard, that is available when clicking the setup the wiki link on your wiki
page.

When the installation wizard asks you for the database setup change the database
name to wikidb (remember, you created it earlier), the database user to wikiuser
(you created it earlier) and the database password to the one you chose when
creating the wikiuser.

When the installation wizard asks you for a name of the wiki and a username and
password, enter your name for the wiki and chose a username and password you can
remember. Select "Ask me more questions." before pressing the "continue" button.

In the options overview, uncheck the box 'Enable outbound mail'.

All other options can safely be confirmed by pressing the continue button.

Finally, the wizard will install the wiki and you will automatically download a
LocalSettings.php that needs to be copied into the wiki folder of the server.

For this task there are multiple solutions, depending on the system where you
downloaded the LocalSettings.php:

(Linux/Mac) use scp to copy the file to your server:

`scp LocalSettings.php ubuntu@134.60.64.95:~/mediawiki-1.30.0/`

(Windows) use the graphical https://winscp.net/eng/index.php to copy the file inside the folder `mediawiki-1.30.0/` in the ubuntu home directory.

(Both) use an editor like vim or nano to open and create a LocalSettings.php on your vm and then paste the content of the downloaded file.

Finally, you can access your new mediawiki installation via http://134.60.64.Y/wiki/index.php/Main_Page

## Question: One Instance for Database and Application

So far, we have installed the mariaDB database server on the same server as the
mediawiki application and linked them using the localhost address.

Can you explain why this is good for performance in the current case, but may
hinder the performance in the long run?

What alternative approach do you suggest?

In the last exercises, we have deployed and configured a Web-based application
(mediawiki) in the cloud.

However, your mediawiki installation is currently running on only one virtual
host, which is hindering scalability and elasticity. This is definitely not good
enough for a large installation as the Wikipedia Foundation uses it for the
well-known Wikipedia.

Can you find out what we need to do to cater for a larger, multi-node
installation of mediawiki?

The Mediawiki architecture overview https://www.mediawiki.org/wiki/Manual:MediaWiki_architecture may prove helpful.

## Task: Create a snapshot

To backup the work you have done in the previous steps, and to be able to
restore your virtual machine quickly, please create a snapshot of your virtual
machine.

In the instances overview of the OpenStack dashboard, click the "Create
Snapshot" Button next to your instance.

This process may take some time.