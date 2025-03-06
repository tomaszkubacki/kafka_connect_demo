## Stream schemaless events to PostgreSQL table

In this scenario we will stream kafka schemaless messages into PostgreSQL table using JdbcSinkConnector.
JdbcSinkConnector requires, that messages have schema, hence we will wrap messages 
into schema using custom *SimpleSchemaWrappingConverter* which can be found [here](https://github.com/tomaszkubacki/schema_wrapping)

>[!NOTE]
> Make sure all necessary containers are up and running as defined in the docker-compose.yml file
> and all prerequisites steps are fulfilled as defined in the root README

## Kafka to PostgreSQL steps

1. Add Kafka connector stored in *kafka_to_postgres.json*
 
   ```shell
   curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_postgresql.json"
   ```
   > [TIP]
   > you can see connector statues, definition in the *akhq* ui
   > running at http://localhost:8080 (assuming root docker-compose was used)

2. Pass message to *kafka_sink* topic

   publish example message the *kafka_sink* topic
   ```
   {"id":"a", "message": "b"}
   ```

   using *kafka-console-producer* in broker container.

   ```shell
   docker exec broker sh -c 'echo "{\"id\":2, \"message\": \"b\"}" | /bin/kafka-console-producer --bootstrap-server broker:9092 --topic kafka_sink'
   ```
  
   > [!TIP]
   > Alternatively you can use *akhq* to produce a message

3. Check is data is stored in sql database *kafka_sink* in table

   ```shell
     docker exec pg sh -c "psql -d my_db -U docker -c 'select * from kafka_sink'"
   ```

## Troubleshoot and clean up commands

### check if connector is running
```shell 
curl localhost:8083/connectors
```

### check connector errors while publishing messages
```shell
docker logs kafka-connect
```

### check connector *kafka_to_postgres* config

```shell 
curl -i localhost:8083/connectors/kafka_to_postgres
```

#### delete connectora *kafka_to_postgres*

```shell 
curl -i -X DELETE localhost:8083/connectors/kafka_to_postgres
```

### add connector stored in *kafka_to_postgresql.json*

```shell
curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_postgresql.json"
```

### delete messages in message table

```shell
  docker exec pg sh -c "psql -d my_db -U docker -c 'delete from kafka_sink where 1 = 1'"
```

## Links

- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/
