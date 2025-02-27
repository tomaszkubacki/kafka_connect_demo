## Stream events to MS SQL Server table

In this scenario we will stream kafka messages (without shema) into Sql Server table using JdbcSinkConnector.

JdbcSinkConnector requires, that messages are schema based, hence we will wrap messages 
into schema using *SimpleSchemaWrappingConverter* which can found [here](https://github.com/tomaszkubacki/schema_wrapping)


>[!TIP]
>Make sure all containers are up and running as defined in root docker-compose.yml file

### Kafka to SqlServer steps

1. Create database *kafka_sink*, create table *kafka_sink* 

create a database 
```shell
docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -U SA -P Hard2Guess -Q "create database kafka_sink"'
```

copy *kafka_sink* table definition *kafka_sink.sql* into Sql Server container
```shell
docker cp kafka_sink.sql sql-server:/tmp/kafka_sink.sql
```

create table defined in kafka_sink.sql
```shell
docker exec sql-server sh -c "/opt/mssql-tools18/bin/sqlcmd -C -d kafka_sink -U SA -P Hard2Guess -i /tmp/kafka_sink.sql"
```

check if it works
```shell
docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -d kafka_sink -U SA -P Hard2Guess -Q "select * from kafka_sink"'
```
this should return empty table result

2. Add Kafka connector stored in *kafka_to_sql_server.json*

register the connector itself. Definition is in the *kafka_to_sql_server.json* file
```shell
curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_sql_server_schemaless.json"
```

3. Pass message to *kafka_sink* topic

publish following content on the topic *kafka_sink* 
```
{"id":"a", "message": "b"}
```

using *kafka-console-producer* shipped in a schema-registry container.
  
```shell
docker exec broker  sh -c 'echo "{\"id\":\"a\", \"message\": \"b\"}" | /bin/kafka-console-producer --bootstrap-server broker:9092 --topic kafka_sink'
  ```
  
> [!TIP]
> Alternatively you can use akhq web ui

4. check is data is stored in *kafka_sink* table


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

#### check connector *kafka_to_sql_server_schemaless* config

```shell 
curl -i localhost:8083/connectors/kafka_to_sql_server_schemaless
```

#### delete connector  *kafka_to_sql_server_schemaless*

```shell 
curl -i -X DELETE localhost:8083/connectors/kafka_to_sql_server_schemaless
```

#### add connector stored in *kafka_to_sql_server.json*

```shell
curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_sql_server_schemaless.json"
```

#### delete messages in kafka_sink table

```shell
docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -d kafka_sink -U SA -P Hard2Guess -Q "delete from kafka_sink where 1 = 1"'
```

### Links

- https://docs.confluent.io/cloud/current/connectors/cc-microsoft-sql-server-sink.html
- https://stackoverflow.com/questions/68200588/kafka-connect-jdbc-source-connector-jdbc-sink-connector-mssql-sql-server
- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/
- https://stackoverflow.com/questions/76584938/how-to-handle-nested-arrays-of-struct-in-kafka-jdbc-sink-connector
