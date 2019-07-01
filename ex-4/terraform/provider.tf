provider "openstack" {
  // Get the user, tenant and auth_url from "Project > API Access > View Credentials"
  user_name   = ""
  tenant_name = "" // called "Project Name" in Dashboard
  auth_url    = ""

  // either place your password here or use the environment variable OS_PASSWORD
  password    = ""

  // don't touch the next values
  domain_name = "default"
}

locals {
  // Provide the KeyPair Name you created in OpenStack
  keypair = ""

  // don't touch the next values
  region = "RegionOne"
  image = "ubuntu-1604"
  extnet_id = "940f32cd-f23f-41f8-9b9e-07fd77cc503a"
  extnet_name = "extnet"
  small_flavour = "small"

}