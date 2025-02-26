### Stream shemaless events to PostgreSQL table

In this scenario we will stream kafka schemaless messages into PostgreSQL table using JdbcSinkConnector.
JdbcSinkConnector requires, that messages are schema based, hence we will wrap messages 
into schema using *SimpleSchemaWrappingConverter* which can found [here](https://github.com/tomaszkubacki/schema_wrapping)

## Kafka to PostgreSQL steps

1. Create table *kafka_sink* in *my_db*
First we copy message message.sql into PostgreSql container
  ```shell
  docker cp kafka_sink.sql pg:/tmp/kafka_sink.sql
  ```
  then we create table defined in kafka_sink.sql
  ```shell
  docker exec pg sh -c "psql -d my_db -U docker -f /tmp/kafka_sink.sql"
  ```
  finally we can check if it works
  ```shell
  docker exec pg sh -c "psql -d my_db -U docker -c 'select * from kafka_sink'"
  ```
  this should return empty table result

2. Add Kafka connector stored in *kafka_to_postgres.json*

  Here we register connector itself. Definition is in the *kafka_to_postgres.json* file
  ```shell
  curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_postgresql.json"
  ```

4. Pass message to *kafka_sink* topic

  Now we need to publish following content on a topic *kafka_sink* 
  ```
  {"id":"a", "message": "b"}
  ```
  
  using *kafka-console-producer* in broker container.

  ```shell
  docker exec broker sh -c 'echo "{\"id\":1, \"message\": \"b\"}" | /bin/kafka-console-producer --bootstrap-server broker:9092 --topic kafka_sink'
  ```
  
> [!TIP]
> Alternatively you can use akhq web ui 

5. check is data is stored in sql database *kafka_sink* in table


```shell
  docker exec pg sh -c "psql -d my_db -U docker -c 'select * from kafka_sink'"
```

## Troubleshoot and clean up commands

### check if connector is running
```shell 
curl localhost:8083/connectors
```

### check connector errors while publishing messages
```
docker logs kafka-connect
```

### check connector *kafka_to_postgres* config

```shell 
curl -i localhost:8083/connectors/kafka_to_postgres
```

### delete connectora *kafka_to_postgres*

```shell 
curl -i -X DELETE localhost:8083/connectors/kafka_to_postgres
```

### add connector stored in *kafka_to_postgresql.json*

```shell
curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_postgresql.json"
```

### delete messages in message table

```shell
TODO
```

## Links

- https://docs.confluent.io/cloud/current/connectors/cc-microsoft-sql-server-sink.html
- https://stackoverflow.com/questions/68200588/kafka-connect-jdbc-source-connector-jdbc-sink-connector-mssql-sql-server
- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/
- https://stackoverflow.com/questions/76584938/how-to-handle-nested-arrays-of-struct-in-kafka-jdbc-sink-connector
- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained
