resource "openstack_compute_secgroup_v2" "web" {
  name        = "web"
  description = "Allows access to web service via tcp 80"
  region      = "RegionOne"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

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

resource "openstack_compute_secgroup_v2" "monitoring" {
  name        = "monitoring"
  description = "Allows access to influxdata monitoring stack"
  region      = "RegionOne"

  rule {
    from_port   = 8086
    to_port     = 8086
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8088
    to_port     = 8088
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 8888
    to_port     = 8888
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}
