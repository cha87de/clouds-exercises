# Lesson 2: Concept of Reliability and Availability

So far in the exercises we focused on scalability of stateless application
layers (e.g. the web server). Handling state in distributed systems is generally
a challenging task, especially in large scale systems with high demand on
availability.

## Research: Consistency Guarantees

Do some research on consistency guarantees: ACID and eventual consistency

Further, look at the trade offs between consistency and availability guarantees:
CAP theorem and BASE (Basically Available, Soft state, Eventual consistency)

Related Articles:
 - [Eventually Consistent, Werner Vogels (Amazon.com), 2009](https://dl.acm.org/citation.cfm?id=1435432)
 - [ACID versus BASE for database transactions, John D. Cook, 2009](https://www.johndcook.com/blog/2009/07/06/brewer-cap-theorem-base/)
 - [Problems with CAP, and Yahoo’s little known NoSQL system, Daniel Abadi, 2010](http://dbmsmusings.blogspot.com/2010/04/problems-with-cap-and-yahoos-little.html)

## Questions: Consistency Guarantees

 * What is ACID? What is eventual consistency?
 * What are the three categories of CAP?
 * What are examples for CA data store? What are examples for AP? And for CP?

## Research: Distributed Database Systems

To store state information in Cloud applications, database systems are very
popular. If the application has to scale, the database system eventually has to
scale and hence distribute as well.

Do some research about distributed database systems, and the features the
database systems have to support to be scalable.

Related Articles:
 - [Reliability and Availability Properties of Distributed Database Systems](https://ieeexplore.ieee.org/abstract/document/6972071)

## Questions: Distributed Database Systems

 * What is the difference between replication and sharding/partitioning?
 * How does replication relate to the CAP theorem?
 * How does sharding relate to the CAP theorem?
 * How would the perfect Cloud database system look like?