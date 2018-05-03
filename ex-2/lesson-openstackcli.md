# Lesson 3: OpenStack APIs and CLI

OpenStack is an API driven software system: all interactions (e.g. working with the OpenStack Dashboard) issue requests to REST interfaces. Available REST API endpoints are listed in the OpenStack Dashboard (Project > Compute > API Access).

The API driven approach allows to use other clients like third party tools or the official OpenStack command line client.

## Task: Install and use OpenStack CLI

To explore the features provided by the OpenStackClient, install it on your machine:

https://docs.openstack.org/python-openstackclient/pike/#getting-started

Next, download the "OpenStack RC File v3" from the API Access site on the OpenStack Dashboard. Inside a terminal, you need to `source` this file, in order to load your credentials to the current terminal.

## Task: Explore the OpenStack CLI

After a successful installation, make sure you sourced the credentials into your current terminal.

Then explore the OpenStack CLI, e.g. `openstack server list`.

Can you manage to create the instances from exercise 1 and 2 via the OpenStack CLI only?
