#!/usr/bin/env bash

################################## GET KAFKA CLUSTER ID ########################
ZK_CONTAINER=ip-172-31-17-205.eu-west-1.compute.internal
ZK_PORT=2181
echo "Retrieving Kafka cluster id zookeeper '$ZK_CONTAINER' port '$ZK_PORT'"
KAFKA_CLUSTER_ID=$( zookeeper-shell $ZK_CONTAINER:$ZK_PORT get /cluster/id 2> /dev/null | grep \"version\" | jq -r .id)
if [ -z "$KAFKA_CLUSTER_ID" ]; then
    echo "Failed to retrieve kafka cluster id from zookeeper"
    exit 1
fi

## Login into MDS
XX_CONFLUENT_USERNAME=admin XX_CONFLUENT_PASSWORD=admin confluent login --url http://ip-172-31-21-162.eu-west-1.compute.internal:8091

SUPER_USER=admin
SUPER_USER_PASSWORD=admin
SUPER_USER_PRINCIPAL="User:$SUPER_USER"

## Create Service Roles
C3_PRINCIPAL="User:hermes"

CONNECT=connect-cluster

echo "Creating C3 role bindings"

# C3 only needs SystemAdmin on the kafka cluster itself
confluent iam rolebinding create \
    --principal $C3_PRINCIPAL \
    --role SystemAdmin \
    --kafka-cluster-id $KAFKA_CLUSTER_ID

echo "Finished setting up role bindings"
echo "    kafka cluster id: $KAFKA_CLUSTER_ID"
echo
echo "    super user account: $SUPER_USER_PRINCIPAL"
echo "    C3 service account: $C3_PRINCIPAL"
