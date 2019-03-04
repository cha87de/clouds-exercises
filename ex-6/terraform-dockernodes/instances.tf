# define cloud-init files and resolve variables from terraform
data "template_file" "init_dockernode" {
  template = "${file("init_dockernode")}"
}

# create dockernode 1
resource "openstack_compute_instance_v2" "dockernode1" {
  name            = "dockernode1"
  image_name      = "${local.image}"
  flavor_name     = "${local.small_flavour}"
  key_pair        = "${local.keypair}"
  region          = "${local.region}"  
  security_groups = ["default", "web", "dockerregistry"]


  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_dockernode.rendered}"
}

resource "openstack_networking_floatingip_v2" "fip_dockernode1" {
  pool   = "${local.extnet_name}"
  region = "${local.region}"
}

resource "openstack_compute_floatingip_associate_v2" "fip_dockernode1" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_dockernode1.address}"
  instance_id = "${openstack_compute_instance_v2.dockernode1.id}"
  region = "${local.region}"
}

output "dockernode1_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_dockernode1.address}"
}

# create dockernode 2
resource "openstack_compute_instance_v2" "dockernode2" {
  name            = "dockernode2"
  image_name      = "${local.image}"
  flavor_name     = "${local.small_flavour}"
  key_pair        = "${local.keypair}"
  region          = "${local.region}"  
  security_groups = ["default", "web", "dockerregistry"]

  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_dockernode.rendered}"
}

resource "openstack_networking_floatingip_v2" "fip_dockernode2" {
  pool   = "${local.extnet_name}"
  region = "${local.region}"
}

resource "openstack_compute_floatingip_associate_v2" "fip_dockernode2" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_dockernode2.address}"
  instance_id = "${openstack_compute_instance_v2.dockernode2.id}"
  region = "${local.region}"
}

output "dockernode2_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_dockernode2.address}"
}

# create dockernode 3
resource "openstack_compute_instance_v2" "dockernode3" {
  name            = "dockernode3"
  image_name      = "${local.image}"
  flavor_name     = "${local.small_flavour}"
  key_pair        = "${local.keypair}"
  region          = "${local.region}"  
  security_groups = ["default", "web", "dockerregistry"]

  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_dockernode.rendered}"
}

resource "openstack_networking_floatingip_v2" "fip_dockernode3" {
  pool   = "${local.extnet_name}"
  region = "${local.region}"
}

resource "openstack_compute_floatingip_associate_v2" "fip_dockernode3" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_dockernode3.address}"
  instance_id = "${openstack_compute_instance_v2.dockernode3.id}"
  region = "${local.region}"
}

output "dockernode3_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_dockernode3.address}"
}
