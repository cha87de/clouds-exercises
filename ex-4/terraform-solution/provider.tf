provider "openstack" {
  // Get the user, tenant and auth_url from "Project > API Access > View Credentials"
  user_name   = ""
  tenant_name = "" // called "Project Name" in Dashboard
  auth_url    = ""

  // either place your password here or use the environment variable OS_PASSWORD
  //password    = "" 

  // don't touch the next values
  domain_name = "default"
}

locals {
  // Provide the KeyPair Name you created in OpenStack
  keypair = ""

  // don't touch the next values
  region = "Freiburg"
  image = "Ubuntu 16.04"
  extnet_id = "f76e9bc0-abbc-44ef-a9fc-7fa388d4c677"
  extnet_name = "public-extended"
  small_flavour = "m1.small"

}