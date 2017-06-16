# define cloud-init files and resolve variables from terraform
data "template_file" "init_ranchernode" {
    template = "${file("init_ranchernode")}"
}

# create dockernode 1
resource "openstack_compute_instance_v2" "rancher" {
	name = "rancher"
	image_name = "Ubuntu Server 16.04 RAW"
	flavor_name = "m1.small"
	key_pair = "YOUR KEY PAIR"
	security_groups = ["default", "dockerregistry", "rancher"]
	region	= "Ulm"
	network {
		uuid = "${openstack_networking_network_v2.private-net.id}"
	}
	user_data = "${data.template_file.init_ranchernode.rendered}"
}
resource "openstack_networking_floatingip_v2" "fip_rancher" {
  pool = "routed"
  region = "Ulm"  
}
resource "openstack_compute_floatingip_associate_v2" "fip_rancher" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_rancher.address}"
  instance_id = "${openstack_compute_instance_v2.rancher.id}"
  region = "Ulm"
}
output "rancher_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_rancher.address}"
}

