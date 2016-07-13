This folder structure contains the Dockerfiles for building RabbitMQ cluster - the number of nodes are completely customizable using https://docs.docker.com/compose/[docker-compose] docker-compose.yml file.


Structure:
==========
There are 3 folders.

1. base - the base Dockerfile is based on an Ubuntu image with RabbitMQ installations.
2. server - This builds on the base image and has the startup script for bring up a RabbitMQ server
4. cluster - This contains a https://docs.docker.com/compose/[docker-compose] definition file(docker-compose.yml) for brining up the rabbitmq cluster. Use `docker-compose up -d` to bring up the cluster.



Running the Cluster:
===============================
Once the images are built, boot up the cluster using the docker-compose.yml configuration provided in cluster folder:    

[source]
----
docker-compose up -d
----

By default 3 nodes are started up this way:

[source]
----
rabbit1:
  image: relaxart/rabbitmq-server
  hostname: rabbit1
  ports:
    - "5672:5672"
    - "15672:15672"

rabbit2:
  image: relaxart/rabbitmq-server
  hostname: rabbit2
  links:
    - rabbit1
  environment: 
   - CLUSTERED=true
   - CLUSTER_WITH=rabbit1
   - RAM_NODE=true
  ports:
      - "5673:5672"
      - "15673:15672"

rabbit3:
  image: relaxart/rabbitmq-server
  hostname: rabbit3
  links:
    - rabbit1
    - rabbit2
  environment: 
   - CLUSTERED=true
   - CLUSTER_WITH=rabbit1   
  ports:
        - "5674:5672"  
----

if needed, additional nodes can be added to this file. If the entire cluster comes up, the management console can be accessed at http://<dockerip>:15672

and connection host should look like this: `dockerip:5672,dockerip:5673,dockerip:5674`