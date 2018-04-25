# Lesson 1: Monitoring with InfluxData

## Research: InfluxData TICK stack

First we need a new Instance/VM, which will host the monitoring data and provide a web-based dashboard to access it. The monitoring solution we will use is the TICK stack of InfluxData.
While Telegraf will run on the VM with Mediawiki installed, we need another VM for InfluxDB and Chronograf.

Become familiar with InfluxData: https://www.influxdata.com/products/open-source/

## Question: Parts and responsibilities of the TICK stack

Please describe the components of the TICK stack and their purpose. Which of these components are needed for a minimum TICK setup?

## Task: Install the monitoring data sink

We will now install the InfluxDB and Chronograf in a new VM, which will be the data sink for several Telegraf monitoring adaptors. This guide follows the official installation guide:

https://docs.influxdata.com/influxdb/v1.2/introduction/installation/

Create a new security group on OpenStack (go to "Network" and "Security Groups"):

- Name: monitoring
- Create, and go to "manage rules":
    - Add Rules for TCP ingres ports 8888, 8086, 8088

Create a new instance on OpenStack:

- Name: monitoring
- Source: Create new Volume set to "No", then select Ubuntu Server 16.04 (ubuntu-1604)
- Flavor: select "compute_medium"

- Select both the default and the monitoring security groups
- Validate that your ssh key and the public network are selected

Log in via SSH to the new vm with username "ubuntu" and the public IP you got assigned. In the new vm, install InfluxDB and Chronograf:

```
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update && sudo apt-get install influxdb
sudo service influxdb start
wget https://dl.influxdata.com/chronograf/releases/chronograf_1.3.0_amd64.deb
sudo dpkg -i chronograf_1.3.0_amd64.deb
```

In your monitoring VM you should have two services influxdb and chronograf running now. Validate that both are running, using the `systemctl` command.

Access the chronograf dashboard via your webbrowser, pointing to your public IP of the monitoring vm and port 8888 (http://134.60.64.YZ:8888). Tell Chronograf where InfluxDB is located:

- Connection String: http://localhost:8086
- Name: InfluxDB
- Username and Password empty!
- Telegraf database: telegraf
- Check the "Make this the default source" box
- Click "add source" button.

You will then see a empty list of hosts. Let's install the Telegraf on the Mediawiki page, to have some data to display :-)

## Question: What ports are used by influxdb?
Now that you have InfluxDB and Chronograf running, what ports are used by InfluxDB? You can get this information from your monitoring VM or from the documentation.

Hint: In the monitoring VM run `sudo netstat -tulpen` to get all ports that are open. Find the InfluxDB application.

## Task: Add monitoring to mediawiki 
Next, connect via SSH to the VM hosting your mediawiki. Let's install Telegraf, which will collect monitoring statistics and send it to the monitoring VM.

```
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" \
    | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update && sudo apt-get install telegraf
sudo service telegraf start
```

We need to configure telegraf to point to your monitoring vm. Open as root (with sudo) e.g. with vim the file /etc/telegraf/telegraf.conf. In the `[[outputs.influxdb]]` section change the urls field from `urls = ["http://localhost:8086"]` to point to the public IP address of your monitoring vm.

Restart telegraf with `service telegraf restart` and check the Chronograf dashboard. You should see monitoring data from host "main-server" now. You will see the basic system metrics of this vm. Let's add monitoring data from apache and mariadb next. Re-open the file /etc/telegraf/telegraf.conf and uncomment the following lines:

```
...
[[inputs.apache]]
   urls = ["http://localhost/server-status?auto"]
...
[[inputs.mysql]]
   servers = ["root:PASSWORD_FOR_DATABASE@tcp(127.0.0.1:3306)/"]
...
```

Now restart again telegraf, to apply your changes to the configuration. After some seconds, check the chronograf dashboard again. You have apache2 and mysql monitoring data now as well.