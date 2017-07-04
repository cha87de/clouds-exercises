# define cloud-init files and resolve variables from terraform
data "template_file" "init_openshift-master" {
    template = "${file("init_openshift-master")}"
		vars {
			node1_ip = "${openstack_compute_instance_v2.openshift-node1.access_ip_v4}"
			node2_ip = "${openstack_compute_instance_v2.openshift-node2.access_ip_v4}"
			node3_ip = "${openstack_compute_instance_v2.openshift-node3.access_ip_v4}"
  	}
}
data "template_file" "init_openshift-node" {
    template = "${file("init_openshift-node")}"
}

# create openshift-master
resource "openstack_compute_instance_v2" "openshift-master" {
	name = "openshift-master"
	#image_name = "CentOS Server 7-1608 RAW"
	image_name = "Centos7-2017-07-04"
	flavor_name = "m1.medium"
	key_pair = "bwcloud"
	security_groups = ["default", "openshift"]
	region	= "Ulm"
	network {
		uuid = "${openstack_networking_network_v2.private-net.id}"
	}
	user_data = "${data.template_file.init_openshift-master.rendered}"
}
# create floating ip for openshift-master
resource "openstack_networking_floatingip_v2" "fip_openshift-master" {
  pool = "routed"
  region = "Ulm"  
}
# attach floating ip to openshift-master vm
resource "openstack_compute_floatingip_associate_v2" "fip_openshift-master" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_openshift-master.address}"
  instance_id = "${openstack_compute_instance_v2.openshift-master.id}"
  region = "Ulm"
}

# create openshift-node1
resource "openstack_compute_instance_v2" "openshift-node1" {
	name = "openshift-node1"
	#image_name = "CentOS Server 7-1608 RAW"
	image_name = "Centos7-2017-07-04"
	flavor_name = "m1.medium"
	key_pair = "bwcloud"
	security_groups = ["default", "openshift"]
	region	= "Ulm"
	network {
		uuid = "${openstack_networking_network_v2.private-net.id}"
	}
	user_data = "${data.template_file.init_openshift-node.rendered}"
}

# create openshift-node1
resource "openstack_compute_instance_v2" "openshift-node2" {
	name = "openshift-node2"
	#image_name = "CentOS Server 7-1608 RAW"
	image_name = "Centos7-2017-07-04"
	flavor_name = "m1.medium"
	key_pair = "bwcloud"
	security_groups = ["default", "openshift"]
	region	= "Ulm"
	network {
		uuid = "${openstack_networking_network_v2.private-net.id}"
	}
	user_data = "${data.template_file.init_openshift-node.rendered}"
}

# create openshift-node1
resource "openstack_compute_instance_v2" "openshift-node3" {
	name = "openshift-node3"
	#image_name = "CentOS Server 7-1608 RAW"
	image_name = "Centos7-2017-07-04"
	flavor_name = "m1.medium"
	key_pair = "bwcloud"
	security_groups = ["default", "openshift"]
	region	= "Ulm"
	network {
		uuid = "${openstack_networking_network_v2.private-net.id}"
	}
	user_data = "${data.template_file.init_openshift-node.rendered}"
}

output "openshift-master_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_openshift-master.address}"
}

output "openshift-master_ssh_connection" {
  value = "ssh centos@${openstack_networking_floatingip_v2.fip_openshift-master.address}"
}

output "openshift-master_url" {
  value = "access openshift dashboard at https://${openstack_networking_floatingip_v2.fip_openshift-master.address}:8443/"
}
