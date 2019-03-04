# define cloud-init files and resolve variables from terraform
data "template_file" "init_ranchermaster" {
  template = "${file("init_ranchermaster")}"
}

data "template_file" "init_rancherhost" {
  template = "${file("init_rancherhost")}"
}

# create rancher-master
resource "openstack_compute_instance_v2" "rancher-master" {
  name            = "rancher-master"
  image_name      = "${local.image}"
  flavor_name     = "${local.small_flavour}"
  key_pair        = "${local.keypair}"
  region          = "${local.region}"  
  security_groups = ["default", "web", "dockerregistry"]

  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_ranchermaster.rendered}"
}

resource "openstack_networking_floatingip_v2" "fip_rancher-master" {
  pool   = "${local.extnet_name}"
  region = "${local.region}"
}

resource "openstack_compute_floatingip_associate_v2" "fip_rancher-master" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_rancher-master.address}"
  instance_id = "${openstack_compute_instance_v2.rancher-master.id}"
  region = "${local.region}" 
}

output "rancher-master_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_rancher-master.address}"
}

# create rancher-host1

resource "openstack_compute_instance_v2" "rancher-host1" {
  name            = "rancher-host1"
  image_name      = "${local.image}"
  flavor_name     = "${local.small_flavour}"
  key_pair        = "${local.keypair}"
  region          = "${local.region}"  
  security_groups = ["default"]

  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_rancherhost.rendered}"
}

resource "openstack_networking_floatingip_v2" "fip_rancher-host1" {
  pool   = "${local.extnet_name}"
  region = "${local.region}"
}

resource "openstack_compute_floatingip_associate_v2" "fip_rancher-host1" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_rancher-host1.address}"
  instance_id = "${openstack_compute_instance_v2.rancher-host1.id}"
  region          = "${local.region}" 
}

output "rancher-host1_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_rancher-host1.address}"
}

resource "openstack_compute_instance_v2" "rancher-host2" {
  name            = "rancher-host2"
  image_name      = "${local.image}"
  flavor_name     = "${local.small_flavour}"
  key_pair        = "${local.keypair}"
  region          = "${local.region}"
  security_groups = ["default"]


  network {
    uuid = "${openstack_networking_network_v2.private-net.id}"
  }

  user_data = "${data.template_file.init_rancherhost.rendered}"
}

resource "openstack_networking_floatingip_v2" "fip_rancher-host2" {
  pool   = "${local.extnet_name}"
  region = "${local.region}"
}

resource "openstack_compute_floatingip_associate_v2" "fip_rancher-host2" {
  floating_ip = "${openstack_networking_floatingip_v2.fip_rancher-host2.address}"
  instance_id = "${openstack_compute_instance_v2.rancher-host2.id}"
  region          = "${local.region}" 
}

output "rancher-host2_floating_ip" {
  value = "${openstack_networking_floatingip_v2.fip_rancher-host2.address}"
}
