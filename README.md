# RABBIT-MQ cluster

This docker image should be used to setup one node of RMQ or cluster with as many nodes as you want.

## Environment variables:

* `CLUSTER_WITH` - should contain node name for clustering with
balancer to avoid lost node apearence (default: `1`)
* `RABBITMQ_CONFIG` - content for file `/var/lib/rabbitmq/rabbitmq.config` (default: `[{rabbit, [{loopback_users, []}]}].`)
* `ERLANG_COOKIE` content for file `/var/lib/rabbitmq/.erlang.cookie` - (default: `ERLANGCOOKIE`)
