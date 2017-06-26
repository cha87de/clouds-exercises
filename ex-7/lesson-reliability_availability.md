# Lesson 2: Concept of Reliability and Availability

So far in the exercises we focused on scalability of stateless application layers (e.g. the web server). 
Handling state in distributed systems is generally a challenging task, especially in large scale systems with
high demand on availability.


## Research: Consistency Guarantees

Do some research on consistency guarantees: ACID and eventual consistency

Further, look at the trade offs between consistency and availability guarantees: CAP theorem and BASE (Basically Available, Soft state, Eventual consistency)

## Questions: Consistency Guarantees

 * What is ACID? What is eventual consistency?
 * What are the three categories of CAP?
 * What are examples for CA data store? What are examples for AP? And for CP?

## Research: Distributed Database Systems

To store state information in Cloud applications, database systems are very popular.
If the application has to scale, the database system eventually has to scale and hence distribute as well.

Do some research about distributed database systems, and the features the database systems have to support
to be scalable.

## Questions: Distributed Database Systems

 * What is the difference between replication and sharding/partitioning?
 * How does replication relate to the CAP theorem?
 * How does sharding relate to the CAP theorem?
 * How would the perfect Cloud database system look like?