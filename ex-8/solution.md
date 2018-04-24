---
date: 2018-07-05
subtitle: "Solution for Exercise 8"
---
# Answers to questions

## Lesson 1: Concepts of Platform as a Service

### Question: Platform as a Service

*What are benefits of PaaS compared to IaaS?*

The user of a PaaS system can focus on writing the application and can completely rely on
the PaaS to run the application instance, without worrying about the infrastructure and
all the challenges of hosting an application.

*What are drawbacks and limitations of PaaS compared to IaaS?*

The user has no control over the infrastructure and has to blindly trust the PaaS provider.
This arises some security/privacy concerns. Further, flexibility is lost, in case some special
requirements towards the infrastructure comes with the application.

### Question: Heroku

*How does Heroku allow you to deploy an application like Mediawiki?*

Heroku, as public PaaS provider, either clones users' git repositories or can be used as an additional
remote git repository to push changes to.
Heroku then deploys the source codes in prepared, programming language specific containers.
For Mediawiki, a git repository should be created and specified in a Heroku deployment. 
Further, Heroku provides services like data bases or third party offers like sending e-mails.

*Which metric and what statistical pattern is used for autoscaling?*

Heroku deployments are meant to be web based applications like REST services or HTML pages. 
Heroku measures the response time for each request. 
The autoscaling relies on the 95th percentile (p95) response time: only 5% of requests will
take longer than the specified value in milliseconds. The percentile is calculated over the last 24 hours.

## Lesson 2: PaaS with OpenShift

### Question: OpenShift

*How does OpenShift allow you to deploy an application like Mediawiki?*

OpenShift allows to deploy source code from a git repository into prepared, programming
language specific containers. OpenShift also offers to deploy Docker images, and
has a Docker registry included to allow users to build Docker images in OpenShift.

*Is OpenShift pure PaaS like Heroku? Why / Why not?*

OpenShift has the feature of taking source code of an application and deploy this software 
in containers. Additionally OpenShift can be used as a kind of "Container as a Service",
where Docker images can be started without any source code from git repositories.
While the first feature is purely PaaS, the second feature goes slightly towards IaaS.