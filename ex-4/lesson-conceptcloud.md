# Lesson 1: Concept of Cloud Computing

Before we continue with the practical part of the exercise, we first need to
understand the characteristics and the concepts of cloud computing.

## Research: Essential Characteristics

According to the *NIST Defition of Cloud Computing* [1] there are several essential characteristics of cloud computing.
Read the document, especially focus on the characteristics.

[1] http://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-145.pdf

## Question: Essential Characteristics

 - What are the essential characteristics according to the NIST Definition of Cloud Computing?

 - What characteristics and features are needed in order to provide "rapid elasticity"?

 - What is the difference between scalability and elasticity?

## Research: Infrastructure and Application Deployment

The cloud stack we used so far looks like the following:

| Cloud Stack | Example | Deployment Tool | 
| --- | --- | --- |
| **Application Component** | Mediawiki | cloud-init |
| **Virtual Resource** | Instance m1.small | Terraform |
| **Cloud Platform** | OpenStack | - |

We started on OpenStack as a Cloud Platform, manually created virtual resources (virtual machines of flavor m1.small) and manually installed the mediawiki application inside the virtual machines.

We will now start automating the manual deployment, from bottom to top. The first tool we will use automates the creation of virtual resources on a cloud platform. Please make yourself familiar with the features presented on the product page of Terraform [1]. The second tool will then automate the deployment of mediawiki inside the virtual resources. Please make yourself familiar with the features of cloud-init [2].

[1] https://www.terraform.io/

[2] https://cloudinit.readthedocs.io/en/latest/

## Question: Infrastructure and Application Deployment

 - What are the three stages a Terraform script walks through?

 - Which cloud platforms are supported by Terraform?

 - How can cloud-init be used to deploy an application inside a virtual machine?
