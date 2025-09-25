# Stream events to MS SQL Server table

In this scenario we will stream Kafka messages (without schema) into Sql Server table using JdbcSinkConnector.

JdbcSinkConnector requires, that messages are schema based, hence we will wrap messages
into schema using _SimpleSchemaWrappingConverter_ and additionally use _AddMetadataTransform_ to add message key, timestamp
and headers to target column

_SimpleSchemaWrappingConverter_ and _AddMetadataTransform_ can found [here](https://github.com/tomaszkubacki/schema_wrapping)

> [!TIP]
> Make sure all containers are up and running as defined in root docker-compose.yml file

### Kafka to SqlServer steps

1. Create database _kafka_sink_ and _kafka_sink_ table

   create a database

   ```shell
   docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -U SA -P Hard2Guess -Q "create database kafka_sink"'
   ```

   copy _kafka_sink.sql_ into Sql Server container

   ```shell
   docker cp kafka_sink.sql sql-server:/tmp/kafka_sink.sql
   ```

   create table defined in kafka_sink.sql

   ```shell
   docker exec sql-server sh -c "/opt/mssql-tools18/bin/sqlcmd -C -d kafka_sink -U SA -P Hard2Guess -i /tmp/kafka_sink.sql"
   ```

2. Add Kafka connector stored in _kafka_to_sql_server.json_

   register the connector itself. Definition is in the _kafka_to_sql_server.json_ file

   ```shell
   curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_sql_server_schemaless.json"
   ```

3. Pass message to _kafka_sink_ topic

   publish following content on the topic _kafka_sink_

   ```
   {"id":"a", "message": "b"}
   ```

   using _kafka-console-producer_ shipped in a schema-registry container.

   ```shell
   docker exec broker  sh -c 'echo "{\"id\":\"a\", \"message\": \"b\"}" | /bin/kafka-console-producer --bootstrap-server broker:9092 --topic kafka_sink'
   ```

   > [!TIP]
   > Alternatively you can use akhq web ui

4. check is data is stored in _kafka_sink_ table

   ```shell
   docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -d kafka_sink -U SA -P Hard2Guess -Q "select * from kafka_sink"'
   ```

### Troubleshoot and clean up commands

#### check if connector is running

```shell
curl localhost:8083/connectors
```

#### check connector errors while publishing messages

```
docker logs kafka-connect
```

#### check connector _kafka_to_sql_server_schemaless_ config

```shell
curl -i localhost:8083/connectors/kafka_to_sql_server_schemaless
```

#### delete connector _kafka_to_sql_server_schemaless_

```shell
curl -i -X DELETE localhost:8083/connectors/kafka_to_sql_server_schemaless
```

#### add connector stored in _kafka_to_sql_server.json_

```shell
curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_sql_server_schemaless.json"
```

#### delete messages in kafka_sink table

```shell
docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -d kafka_sink -U SA -P Hard2Guess -Q "delete from kafka_sink where 1 = 1"'
```

### Links

- <https://docs.confluent.io/cloud/current/connectors/cc-microsoft-sql-server-sink.html>
- <https://stackoverflow.com/questions/68200588/kafka-connect-jdbc-source-connector-jdbc-sink-connector-mssql-sql-server>
- <https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/>
- <https://stackoverflow.com/questions/76584938/how-to-handle-nested-arrays-of-struct-in-kafka-jdbc-sink-connector>
