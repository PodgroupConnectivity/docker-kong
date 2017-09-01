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

if [ -z "$KONG_CASSANDRA_KEYSPACE" ]; then
        KONG_CASSANDRA_KEYSPACE="kong"
else
        sed -i -e "s/^\#cassandra_keyspace = kong/cassandra_keyspace = $KONG_CASSANDRA_KEYSPACE/" $KONG_CONFIG
fi


if [ -z "$KONG_CASSANDRA_PROPAGATION" ]; then
        echo "Propagation is 0"
else
        sed -i -e "s/^\#db_update_propagation = 0/db_update_propagation = $KONG_CASSANDRA_PROPAGATION/" $KONG_CONFIG
fi

if [ -z "$KONG_CASSANDRA_CONSISTENCY" ]; then
        echo "Consistency is ONE"
else
        sed -i -e "s/^\#cassandra_consistency = ONE/cassandra_consistency = $KONG_CASSANDRA_CONSISTENCY/" $KONG_CONFIG
fi

if [ -z "$KONG_CASSANDRA_FREQUENCY" ]; then
        echo "Frequency is 0"
else
        sed -i -e "s/^\#db_update_frequency = 5/db_update_frequency = $KONG_CASSANDRA_FREQUENCY/" $KONG_CONFIG
fi

sed -i -e "s/^\#cassandra_data_centers = dc1:2,dc2:3/cassandra_data_centers = dc1:2/" $KONG_CONFIG

if [ -z "$KONG_DAEMON" ]; then
        echo "Daemon is on"
else
  if [[ $KONG_DAEMON = "off" ]]; then
    sed -i -e "s/^\#nginx_daemon = on/nginx_daemon = $KONG_DAEMON/" $KONG_CONFIG
  fi
fi
count=0
exist=0 #no
IFS=',' read -ra IP <<< "$KONG_CASSANDRA_CONTACTPOINTS"
for i in "${IP[@]}"; do
    cqlsh $i --cqlversion="3.4.4" -u ${CASSANDRA_ADMIN} -p ${CASSANDRA_ADMIN_PASSWORD} \
    -e "CREATE ROLE IF NOT EXISTS ${KONG_CASSANDRA_USERNAME} WITH PASSWORD = '${KONG_CASSANDRA_PASSWORD}' AND LOGIN = true;"
    KEYSPACE="$(cqlsh $i --cqlversion="3.4.4" -u ${CASSANDRA_ADMIN} -p ${CASSANDRA_ADMIN_PASSWORD} \
    -e "SELECT count(*) FROM system_schema.keyspaces WHERE keyspace_name='${KONG_CASSANDRA_KEYSPACE}';" 2> /dev/null | \
    head -n 4 | tail -n 1 | sed -e 's/^[ \t]*//')"
    echo $KEYSPACE
    intKEYSPACE=$((KEYSPACE))
    if [[ "$intKEYSPACE" -gt 0 ]]; then
      exist=1
    fi
    count=$[count+1]

done
echo $intKEYSPACE

if [[ "$exist" -eq 0 ]]; then
  echo "Migrating "${exist}
  kong migrations up
  sleep 120
  exec kong start --conf $KONG_CONFIG --vv

fi

exec kong start --conf $KONG_CONFIG --vv
