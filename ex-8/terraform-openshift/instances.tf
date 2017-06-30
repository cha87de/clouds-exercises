# define cloud-init files and resolve variables from terraform
data "template_file" "init_openshift-master" {
    template = "${file("init_openshift-master")}"
}

# create openshift-master
resource "openstack_compute_instance_v2" "openshift-master" {
	name = "openshift-master"
	image_name = "CentOS Server 7-1608 RAW"
	flavor_name = "m1.large"
	key_pair = "christopher-uulm"
	security_groups = ["default", "openshift"]
	region	= "Ulm"
	network {
		name = "public"
	}
	user_data = "${data.template_file.init_openshift-master.rendered}"
}
output "openshift-master_public_ip" {
  value = "${openstack_compute_instance_v2.openshift-master.access_ip_v4}"
}

