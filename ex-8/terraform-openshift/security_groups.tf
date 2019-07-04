resource "openstack_compute_secgroup_v2" "openshift" {
  name        = "openshift"
  description = "Allows access to openshift instance"
  region	= "Ulm"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8443
    to_port     = 8443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }  

}
