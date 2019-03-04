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
  region = "Ulm"
  image = "Ubuntu 16.04"
  extnet_id = "861f7f5a-60de-4be9-ba70-6802a706cc94"
  extnet_name = "routed-ulm"
  small_flavour = "m1.small"

}