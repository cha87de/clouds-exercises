//variable "password" {}
provider "openstack" {
    user_name   = "ehx27@uni-ulm.de"
    tenant_name = "Projekt_ehx27@uni-ulm.de"
    auth_url    = "https://bwcloud.ruf.uni-freiburg.de:5000/v2.0"
    //password    = "${var.password}"
}