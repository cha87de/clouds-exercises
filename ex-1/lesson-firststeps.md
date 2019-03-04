# Lesson 2: First Steps with Omistack

## Introduction

In this lesson, we will register an account for the OpenStack installation at
hand. **Registration may take a while** - so please register in time, in order to proceed with all remaining tasks, lesson 3 and all the following exercises.

## Task: Register at the OpenStack

Please resume to the **next task only, when you have access to OpenStack**. When
you have access, make yourself familiar with the OpenStack dashboard. Navigate
through the links at the left to remember the dashbaord's sections later on.

## Task: Create an SSH key

In OpenStack, Instances (Virtual Machines, usually Linux servers) are managed
via a SSH connection from your pc. For security reasons, authentication is not
with a password but with keys (cf. lesson 1).

You can create an SSH key within the OpenStack dashboard. Select "Key Pairs" in
the menu. Then press "Create Key Pair". Choose "cloud_key" as "Key Pair Name",
and press the "Create Key Pair" button.

OpenStack will start downloading the private key as a file after it has created
the Key Pair. It is *important that you save and keep this file*, as you will
need it later on and there is no actual way make OpenStack deliver it again.
Backup this private key! If you loose your private key, you won't be able to
access Instances (Virtual Machines) any more!

Alternatively, you can upload an SSH key, which you generated already on your
pc, e.g. using the [ssh-keygen tool](https://linux.die.net/man/1/ssh-keygen).

## Task: Adapt Security Rules

Before we can work with OpenStack, we need to check the firewall rules to allow
remote access. These firewall rules are organised within "security groups". In
the OpenStack dashboard, go to "Network" and "Security Groups". You should see
only the "default" security group. Click on "manage rules". The rules should be
similar to the following ones:

![rules for security group default](imgs/secgroup-default.png)

## Task: Validate your Network

Before starting your first Instance, a basic virtual network is required, if you
want to access and hence use your new instance via OpenStack's virtual network infrastructure.

In the OpenStack dashboard, click the "Network" item in the menu, then select
"Networks". You should see at least one entry in the networks table. The networks listed depend on the OpenStack deployment and may differ.

Virtual Networks will be studied in more detail in exercise 3. If you miss the network, please inform your instructor.

## Task: Launch your first Instance

Virtual machines in OpenStack are called "Instances". Let's start your first
one, by launching an Ubuntu Server. To go "Compute", then "Instances". Then click the "Launch Instance" button on the top right.

In the "Launch Instance" popup, in the "Details" step:

 - Name your instance e.g. "main_server"
 - Select "nova" as availability zone

Continue to the "Source" step:

 - Select Boot Source: Image
 - Create New Volume: No
 - Select in the list "Ubuntu Server 16.04" with the arrow button

In the Flavor tab:

 - Select "small" as flavor

In the Networks tab:

 - The default network should be automatically selected. If not, select it.

In the Security Groups tab:

 - Select the "default" security group

In the Key Pair tab:

 - select the key you previously created (cloud_key)

Finally, launch the virtual machine, by clicking the "Launch Instance" button. This may take from some seconds to a few minutes. The new instance gets an IP address assigned automatically.

Depending on your OpenStack deployment, this IP address may be private or public. If you have a private IP, to access the instance from remote, add a so called "Floating IP". If you have a public IP, skip the following steps.

If you have a private IP, add a Floating IP to your instance:

 - while the instance is spawning, press the "Associate Floating IP" button, after it was spawned, find this option in the drop down menu next to the "create snapshot" button.
 - If you see "No floating IP addresses allocated", then press the "plus" button to allocate a floating IP in the available pool.
 - Select the new floating IP and press the "Associate" button.
 - Your instance has now two IP addresses: the private one from before, and a public one. You need this public one to access your instance via SSH.

## Task: Access your Instance via SSH

It is time to access your new instance via SSH with your favourite SSH client.
Make sure you have your SSH key file at hand. To access your instance, you need the
public IP address from your instance. This IP address is listed in the
OpenStack dashboard, where you launched it.

The **SSH username** for the ubuntu image is **ubuntu**, a password is not set
since we use key based authentication.

Some more hints to access via SSH:

*Windows* For Windows users, we suggest using [putty in combination with
    puttygen](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html).
    An instruction on how to make use of the OpenStack key with putty is
    available
    [here](https://github.com/naturalis/openstack-docs/wiki/Howto:-Creating-and-using-OpenStack-SSH-keypairs-on-Windows)
    in the sections "Converting a Key" and "Using the key with putty".

*Linux / Mac* In Linux or Mac, an SSH client is shipped with almost all
    distributions. Using a key can be enforced by applying the -i command line
    parameter (for details type "man ssh" in a terminal).

If you're asked "Are you sure you want to continue connecting (yes/no)?" you can accept with typing "yes" and pressing enter.