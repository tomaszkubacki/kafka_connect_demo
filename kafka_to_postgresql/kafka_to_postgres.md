## Stream shemaless events to PostgreSQL table

In this scenario we will stream kafka schemaless messages into PostgreSQL table using JdbcSinkConnector.
JdbcSinkConnector requires, that messages are schema based, hence we will wrap messages 
into schema using *SimpleSchemaWrappingConverter* which can found [here](https://github.com/tomaszkubacki/schema_wrapping)

### Kafka to PostgreSQL steps

1. Create table *kafka_sink* in *my_db*

  copy kafka sink table definition into PostgreSql container
  ```shell
  docker cp kafka_sink.sql pg:/tmp/kafka_sink.sql
  ```
  and create table defined in there
  ```shell
  docker exec pg sh -c "psql -d my_db -U docker -f /tmp/kafka_sink.sql"
  ```
  finally check if it works
  ```shell
  docker exec pg sh -c "psql -d my_db -U docker -c 'select * from kafka_sink'"
  ```
  this should return empty table result

2. Add Kafka connector stored in *kafka_to_postgres.json*

  register the connector itself. 
  ```shell
  curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_postgresql.json"
  ```

4. Pass message to *kafka_sink* topic

  publish following content on the topic *kafka_sink* 
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

### Troubleshoot and clean up commands

#### check if connector is running
```shell 
curl localhost:8083/connectors
```

#### check connector errors while publishing messages
```shell
docker logs kafka-connect
```

#### check connector *kafka_to_postgres* config

```shell 
curl -i localhost:8083/connectors/kafka_to_postgres
```

#### delete connectora *kafka_to_postgres*

```shell 
curl -i -X DELETE localhost:8083/connectors/kafka_to_postgres
```

#### add connector stored in *kafka_to_postgresql.json*

```shell
curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_postgresql.json"
```

#### delete messages in message table

```shell
  docker exec pg sh -c "psql -d my_db -U docker -c 'delete from kafka_sink where 1 = 1'"
```

### Links

- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/
