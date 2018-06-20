resource "openstack_compute_secgroup_v2" "dockerregistry" {
  name        = "dockerregistry"
  description = "Allows access to registry service via tcp 5000"
  region      = "RegionOne"

  rule {
    from_port   = 5000
    to_port     = 5000
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "rancher" {
  name        = "rancher"
  description = "Allows access to registry service via tcp 8080"
  region      = "RegionOne"

  rule {
    from_port   = 8080
    to_port     = 8080
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 2376
    to_port     = 2376
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 4500
    to_port     = 4500
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 500
    to_port     = 500
    ip_protocol = "udp"
    cidr        = "0.0.0.0/0"
  }
}
