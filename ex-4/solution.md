---
mainfont: Open Sans
mainfontoptions: BoldFont=Open Sans Bold
mainfontoptions: ItalicFont=Open Sans Italic
mainfontoptions: BoldItalicFont=Open Sans Bold Italic
---
# Answers to questions

## Lesson 1: Concept of Cloud Computing

### Question: Essential Characteristics

 - *What are the essential characteristics according to the NIST Definition of Cloud Computing?*
 

 - *What characteristics and features are needed in order to provide "rapid elasticity"?*

 - *What is the difference between scalability and elasticity?*


### Question: Infrastructure and Application Deployment

 - *What are the three stages a Terraform script walks through?*

 - *Which cloud platforms are supported by Terraform?*

 - *How can cloud-init be used to deploy an application inside a virtual machine?*


## Lesson 2: Concept of Cloud Computing

### Questions: Terraform and cloud-init

 - *Where can you watch and validate the execution of a cloud-init script?*

 - *How does Terraform help you with scaling elastically?*

 - *Can you imagine how to automatically scale your setup when the load increases/decreases?*

# Solution for practical part

You should have six virtual machines in bwcloud after your changes to the Terraform and cloud-init scripts:

![six vms in openstack](imgs/openstack-vms.png)

We will now go through the changes you should have done in detail.

## Add two more mediawiki instances

Changes to instances.tf are required. Copy the following code block and paste it twice:

```
# create first mediawiki instance
resource "openstack_compute_instance_v2" "mediawiki-1" {
	name = "mediawiki-1"
	image_name = "Ubuntu Server 14.04 RAW"
	flavor_name = "m1.small"
	key_pair = "christopher-uulm"
	security_groups = ["default"]
	region	= "Ulm"
	network {
		uuid = "${openstack_networking_network_v2.private-net.id}"
	}
	user_data = "${data.template_file.init_mediawiki.rendered}"
}
```

Make sure to change the two occurences of `mediawiki-1` appropriately.

### Add monitoring vm

Add another `openstack_compute_instance_v2` resource to the instance.tf file, don't forget the monitoring security group (was already part of the security_groups.tf file):

```
resource "openstack_compute_instance_v2" "monitoring" {
	name = "monitoring"
	image_name = "Ubuntu Server 16.04 RAW"
	flavor_name = "m1.small"
	key_pair = "christopher-uulm"
	security_groups = ["default", "monitoring"]
	region	= "Ulm"
	network {
		uuid = "${openstack_networking_network_v2.private-net.id}"
	}
	user_data = "${data.template_file.init_monitoring.rendered}"
}
```

To install Influxdb and Chronograf, you need to create another `template_file` element and reference it accordingly in the `user_data` field of the new resource:
```
data "template_file" "init_monitoring" {
    template = "${file("init_monitoring")}"
}
```

The referenced bash script, which will be passed through into the virtual machine via cloud-init, has to be created. It could look like the following:

```
#!/bin/bash
sudo -s

curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/ubuntu xenial stable" \
    | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update && sudo apt-get install -y influxdb
sudo service influxdb start

wget https://dl.influxdata.com/chronograf/releases/chronograf_1.3.0_amd64.deb
sudo dpkg -i chronograf_1.3.0_amd64.deb
```

Make sure, that your Chronograf dashboard works as expected.

### Add Telegraf to all your vms

We need to extend the bash script for each of the vms. At the end of each `init_*` file, you should add something like the following:

```
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/ubuntu xenial stable" \
    | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt-get update && sudo apt-get install -y telegraf
## configure telegraf
echo "[global_tags]
[agent]
  interval = \"10s\"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = \"0s\"
  flush_interval = \"10s\"
  flush_jitter = \"0s\"
  precision = \"\"
  debug = false
  quiet = false
  logfile = \"\"
  hostname = \"\"
  omit_hostname = false
[[outputs.influxdb]]
  urls = [\"http://${monitoring-ip}:8086\"] # required
  database = \"telegraf\" # required
  retention_policy = \"\"
  write_consistency = \"any\"
  timeout = \"5s\"
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
[[inputs.disk]]
  ignore_fs = [\"tmpfs\", \"devtmpfs\"]
[[inputs.diskio]]
[[inputs.kernel]]
[[inputs.mem]]
[[inputs.processes]]
[[inputs.swap]]
[[inputs.system]]
[[inputs.nginx]]
  urls = [\"http://localhost/status\"]
" > /etc/telegraf/telegraf.conf

service telegraf restart
```

Make sure to replace the line `echo "deb https://repos.influxdata.com/ubuntu xenial stable" \`, which works for Ubuntu 16.04 only, to
`echo "deb https://repos.influxdata.com/ubuntu trusty stable" \` for Ubuntu 14.04. Also change the inputs as necessary. 
The snippet above will work on the loadbalancer vm, since we use the `inputs.nginx` input adaptor.

You may have noticed the variable `${monitoring-ip}` in the snippet above. This variable needs to be passed through from terraform.
Therefore, change the `vars` for the `data "template_file" "init*` blocks, like:

```
data "template_file" "init_database" {
    template = "${file("init_database")}"
	vars {
		monitoring-ip = "${openstack_compute_instance_v2.monitoring.access_ip_v4}"
	}
}
```

The chronograf dashboard should like:

![chronograf with five telegrafs](imgs/chronograf.png)