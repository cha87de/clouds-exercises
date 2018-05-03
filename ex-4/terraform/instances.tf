# define cloud-init files and resolve variables from terraform
data "template_file" "init_mediawiki" {
  template = "${file("init_mediawiki")}"

  vars {
    public_ip   = "${openstack_networking_floatingip_v2.fip_loadbalancer.address}"
    database_ip = "${openstack_compute_instance_v2.database.access_ip_v4}"
  }
}

data "template_file" "init_database" {
  template = "${file("init_database")}"
}

data "template_file" "init_loadbalancer" {
  template = "${file("init_loadbalancer")}"

  vars {
    server1_ip = "${openstack_compute_instance_v2.mediawiki-1.access_ip_v4}"
  }
}

# create first mediawiki instance
resource "openstack_compute_instance_v2" "mediawiki-1" {
  name            = "mediawiki-1"
  image_name      = "Ubuntu Server 14.04.2 AMD64 LTS"
  flavor_name     = "small"
  key_pair        = "YOUR_KEYPAIR_NAME"
  security_groups = ["default"]
  region          = "RegionOne"

  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_mediawiki.rendered}"
}

# create database server
resource "openstack_compute_instance_v2" "database" {
  name            = "database"
  image_name      = "ubuntu-1604"
  flavor_name     = "small"
  key_pair        = "YOUR_KEYPAIR_NAME"
  security_groups = ["default"]
  region          = "RegionOne"

  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_database.rendered}"
}

# create loadbalancer
resource "openstack_compute_instance_v2" "loadbalancer" {
  name            = "loadbalancer"
  image_name      = "ubuntu-1604"
  flavor_name     = "small"
  key_pair        = "YOUR_KEYPAIR_NAME"
  security_groups = ["default"]
  region          = "RegionOne"

  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_loadbalancer.rendered}"
}

# create floating ip for loadbalancer
resource "openstack_networking_floatingip_v2" "fip_loadbalancer" {
  pool   = "extnet"
  region = "RegionOne"
}

# attach floating ip to loadbalancer vm
resource "openstack_compute_floatingip_associate_v2" "fip_loadbalancer" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_loadbalancer.address}"
  instance_id = "${openstack_compute_instance_v2.loadbalancer.id}"
  region      = "RegionOne"
}

# print floating ip of loadbalancer to user
output "loadbalancer_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_loadbalancer.address}"
}
