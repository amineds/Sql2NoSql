docker run --name debezium_postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgres -d debezium/postgres

docker run -it --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 debezium/zookeeper

docker run -it --name kafka -p 9092:9092 --link zookeeper:zookeeper debezium/kafka

docker run -it --rm --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my_connect_configs -e OFFSET_STORAGE_TOPIC=my_connect_offsets -e STATUS_STORAGE_TOPIC=my_connect_statuses --link zookeeper:zookeeper --link kafka:kafka --link debezium_postgres:postgres debezium/connect:0.8

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{ "name": "inventory-connector", "config": {"connector.class": "io.debezium.connector.postgresql.PostgresConnector","tasks.max": "1","database.hostname": "postgres","database.port": "5432","database.user": "postgres","database.password": "postgres","database.dbname" : "inventory","database.server.name": "dbserver1","database.whitelist": "inventory","database.history.kafka.bootstrap.servers": "kafka:9092","database.history.kafka.topic": "schema-changes.inventory"}}'

docker run -it --name watcher --rm --link zookeeper:zookeeper debezium/kafka watch-topic -a -k dbserver1.public.dumb_table
