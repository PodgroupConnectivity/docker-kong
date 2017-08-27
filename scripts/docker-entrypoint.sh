#!/bin/bash
IP=`hostname --ip-address | cut -f 1 -d ' '`
ALL='0.0.0.0'

if [ -z "$KONG_DATABASE" ]; then
        echo "PostgreSQL by default"
else
        sed -i -e "s/^\#database = postgres/database = $KONG_DATABASE/" $KONG_CONFIG
fi


if [ -z "$KONG_CASSANDRA_CONTACTPOINTS" ]; then
        echo "No contact points"
else
        sed -i -e "s/^\#cassandra_contact_points = 127.0.0.1/cassandra_contact_points = $KONG_CASSANDRA_CONTACTPOINTS/" $KONG_CONFIG
fi

if [ -z "$KONG_CASSANDRA_USERNAME" ]; then
        echo "No Username for cassandra"
else
        sed -i -e "s/^\#cassandra_username = kong/cassandra_username = $KONG_CASSANDRA_USERNAME/" $KONG_CONFIG
fi

if [ -z "$KONG_CASSANDRA_PASSWORD" ]; then
        echo "No password for cassandra user"
else
        sed -i -e "s/^\#cassandra_password =/cassandra_password = $KONG_CASSANDRA_PASSWORD/" $KONG_CONFIG
fi

if [ -z "$KONG_CASSANDRA_STRATEGY" ]; then
        echo "Simple Strategy by default"
else
        sed -i -e "s/^\#cassandra_repl_strategy = SimpleStrategy/cassandra_repl_strategy = $KONG_CASSANDRA_STRATEGY/" $KONG_CONFIG
fi

if [ -z "$KONG_CASSANDRA_FACTOR" ]; then
        echo "Simple Strategy by default"
else
        sed -i -e "s/^\#cassandra_repl_factor = 1/cassandra_repl_factor = $KONG_CASSANDRA_FACTOR/" $KONG_CONFIG
fi


if [ -z "$KONG_CASSANDRA_PROPAGATION" ]; then
        echo "Propagation is 0"
else
        sed -i -e "s/^\#db_update_propagation = 0/db_update_propagation = $KONG_CASSANDRA_PROPAGATION/" $KONG_CONFIG
fi

if [ -z "$KONG_CASSANDRA_FREQUENCY" ]; then
        echo "Frequency is 0"
else
        sed -i -e "s/^\#db_update_frequency = 5/db_update_frequency = $KONG_CASSANDRA_FREQUENCY/" $KONG_CONFIG
fi

if [ -z "$KONG_DAEMON" ]; then
        echo "Daemon is on"
else
  if [[ $KONG_DAEMON = "off" ]]; then
    sed -i -e "s/^\#nginx_daemon = on/nginx_daemon = $KONG_DAEMON/" $KONG_CONFIG
  fi
fi


exec "$@"
