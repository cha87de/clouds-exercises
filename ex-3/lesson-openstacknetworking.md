# Lesson 1: Extend your knowledge about OpenStack

OpenStack does not only provide virtual machines as shown in exercise 1 and 2. OpenStack has lots of projects, which extend the basic feature set.

## Research: OpenStack Projects

Scan the official project navigator page at [1].

[1] https://www.openstack.org/software/project-navigator/

## Question: OpenStack Projects

1. How is the project called, which provides virtual machines in OpenStack?

The compute service is responsible for virtual machines and is called nova. It cannot run alone: Keystone (Identity Service) and Glance (Image Service) are required at least.

2. What are the main differences between Object Store (Swift) and Block Storage (Cinder)?

Object Store is accessible via REST and allows applications to store arbitrary BLOBs. 
Cinder is accessible via iSCSI and provides volumes which can be attached to virtual machines as virtual disks.

## Research: OpenStack Networking
OpenStack provides besides virtual machines virtual networks. The virtual network can be bridged to a public network or can be a private one.
In the exercise so far, we used a public network to attach virtual machines directly to it. To hide some of your virtual machines from the public access, a private network is sometimes more useful. Such a virtual private network is then only accessible within attached virtual machines. To still have access to some of your virtual machines from the public, so called *floating IPs* can be used. Floating IPs can be assigned manually to virtual machines, while other IPs from public or private networks are assigned automatically by DHCP.

## Question: Floating IPs vs. DHCP
What are the benefits and drawbacks of the manual assignment of floating IPs to virtual machines, compared to the automatic assignment in DHCP?

## Task: OpenStack Networking
For the next steps in our exemplary mediawiki application, let's switch from plain public IPs to a virtual private network and public floating IPs.

### Create a private network in OpenStack
In OpenStack, go to "Network -> Networks".
Click "Create Network". Define the following settings:

 - Network:
    - Network name: "private-net"
    - Admin State: "Up"
    - Create Subnet: Checked
 - Subnet:
    - Subnet Name: "private-subnet"
    - Network Adress: "192.168.5.0/24"
    - IP Version: IPv4
    - Gateway IP: <empty>
    - Disable Gateway: unchecked
 - Subnet Details:
    - Enable DHCP: Checked
    - Everything else: <empty> 

### Create a private router

The private network can now be used, virtual machines will get IP addresses automatically via DHCP. Yet, there is no connection to the public internet so far. Therefore we need a virtual router, which connects the private virtual network with the public network. Without this router, no public floating IPs can be assigned.

Go to "Network -> Routers". Click Create Router. Define the following settings:

 - Name: "my-router"
 - External Gateway: "routed"

Go to tab "Interface" of this router. Click "Add interface". Define the following settings:

 - Subnet: "private-subnet"
 - Everything else is default

From now on you should be able to create VMs in the network "private-net". These VMs will get a private IP address via DHCP. To access these VMs from the public internet, you can assign a floating IP to VMs which need public access. Not all VMs necessarily need to be accessible publicly (e.g. a database server). To still have a SSH connection you can do ssh hopping: log in to a VM with floating IP and from there tunnel through the VM you want to access. For more details, check the man pages of ssh [1] and search for ProxyCommand.

[1] https://linux.die.net/man/5/ssh_config

### Move main_server to private network
We will now attach the existing virtual machine named main_server with the mediawiki application to the new private network. 

- In the menu list of the main_server instance, select "attach interface"
- Select "private-net" and press "attach interface" button
- Verify, that your instance now has two interfaces (the existing one in network "public" and the new one in "private-net")
- In the menu list of the main_server instance, select "detach interface"
- Select the address from the public network, and press the button to continue.
- Verify, that your instance now has only one interface with a private IP address (192.168.5.x)
- "Soft Reboot" the instance via the openstack dashboard to make sure it sets the new IP routing correctly.

The virtual machine is now not accessible any more from the outside. In lesson 3 we will create a new vm with a floating IP, from which you can tunnel through to your private network.
