#!/bin/bash

set -e

function is_cluster_part {

	CLUSTER_CONFIG_FILE="/var/lib/rabbitmq/mnesia/$RABBITMQ_NODENAME/cluster_nodes.config"
	if [ ! -f $CLUSTER_CONFIG_FILE ]; then
		echo "false"
		exit 0
	fi

	NUMBER=`cat "$CLUSTER_CONFIG_FILE" | grep "$RABBITMQ_NODENAME" | wc -l`

	if [[ "$NUMBER" != 0 ]]; then
		echo "true"
	else
		echo "false"
	fi
}

function join_cluster {
	rabbitmqctl stop_app
	if [ -z "$RAM_NODE" ]; then
		rabbitmqctl join_cluster rabbit@$CLUSTER_WITH
	else
		rabbitmqctl join_cluster --ram rabbit@$CLUSTER_WITH
	fi
	rabbitmqctl start_app
}

if [ -z "$RABBITMQ_NODENAME" ]; then
	export RABBITMQ_NODENAME="rabbit@$(hostname)"
fi
echo " > RABBITMQ_NODENAME=$RABBITMQ_NODENAME"
HOST=`echo $RABBITMQ_NODENAME | awk -F @ '{print $2}'`
echo "$HOST 127.0.0.1" >> /etc/hosts # Resolve it without external connection

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
	CLUSTERED=$(is_cluster_part)

	if [[ "$CLUSTERED" == "true" ]]; then
	    echo "Node has been added to the cluster - no need to join it again!"
	else
		echo "Starting clustered node ($CLUSTER_WITH)..."
		sleep 10
		dockerize -wait tcp://$CLUSTER_WITH:4369 -timeout "$WAIT_CLUSTERED_WITH"
		dockerize -wait tcp://$CLUSTER_WITH:25672 -timeout "$WAIT_CLUSTERED_WITH"
		join_cluster &
	fi

fi



/usr/sbin/rabbitmq-server