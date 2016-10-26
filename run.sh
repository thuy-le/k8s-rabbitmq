#!/bin/bash

set -e

function join_cluster {
	dockerize -wait tcp://$CLUSTER_WITH:4369 -timeout 250s
	dockerize -wait tcp://$CLUSTER_WITH:25672 -timeout 250s
	rabbitmqctl stop_app
	if [ -z "$RAM_NODE" ]; then
		rabbitmqctl join_cluster rabbit@$CLUSTER_WITH
	else
		rabbitmqctl join_cluster --ram rabbit@$CLUSTER_WITH
	fi
	rabbitmqctl start_app
}

# Make sure folder is owned by correct user
chown -R rabbitmq:rabbitmq /var/lib/rabbitmq/

echo "$ERLANG_COOKIE" > /var/lib/rabbitmq/.erlang.cookie
echo "$RABBITMQ_CONFIG" > /etc/rabbitmq/rabbitmq.config

chmod u+rw /etc/rabbitmq/rabbitmq.config 
chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie
chmod 400 /var/lib/rabbitmq/.erlang.cookie


if [ -z "$CLUSTER_WITH" ]; then
	echo 'Starting non-clustered node...'
else
	echo "Starting clustered node ($CLUSTER_WITH)..."
	sleep 10
	join_cluster &
fi



/usr/sbin/rabbitmq-server