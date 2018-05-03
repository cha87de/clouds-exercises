# Define private network
resource "openstack_networking_network_v2" "private-net" {
  name   = "private-net"
  region = "RegionOne"
}

# Define subnet with IP range in private network
resource "openstack_networking_subnet_v2" "private-net-sub" {
  network_id = "${openstack_networking_network_v2.private-net.id}"
  cidr       = "192.168.5.0/24"
  region     = "RegionOne"
}

# Create private router with link to external network
resource "openstack_networking_router_v2" "private-router" {
  name   = "private-router"
  region = "RegionOne"

  #Network Id of public network for floating ips
  external_network_id = "9fcc0c20-1e43-48d2-8712-7d8cb9cf3b8a"
}

# Add interface to private subnet to private router
resource "openstack_networking_router_interface_v2" "private-router-subnet" {
  router_id = "${openstack_networking_router_v2.private-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.private-net-sub.id}"
  region    = "RegionOne"
}
