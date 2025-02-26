### Stream events to MS SQL Server table

In this scenario we will stream kafka event into Sql Server table using JdbcSinkConnector.
JdbcSinkConnector requires, that messages are schema based either by passing schema with payload
or passing schema id.

All the operations will be done with culr or docker - no gui tools required (although possible)


## Kafka to SqlServer steps

1. Create database *my_messages*, create table *message* 
  First we create a database 
  ```shell
  docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -U SA -P Hard2Guess -Q "create database my_messages"'
  ```
  next we copy message message.sql into Sql Server container
  ```shell
  docker cp message.sql sql-server:/tmp/message.sql
  ```
  then we create table defined in message.sql
  ```shell
  docker exec sql-server sh -c "/opt/mssql-tools18/bin/sqlcmd -C -d my_messages -U SA -P Hard2Guess -i /tmp/message.sql"
  ```
  finally we can check if it works
  ```shell
  docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -d my_messages -U SA -P Hard2Guess -Q "select * from message"'
  ```
  this should return empty table result

2. Add Kafka connector stored in *kafka_to_sql_server.json*

  Here we register connector itself. Definition is in the *kafka_to_sql_server.json* file
  ```shell
  curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_sql_server.json"
  ```

3. Register message schema into kafka Schema Registry

  In order to tell connect how to put data into sql server it's required to define a schema. E.g. like this
  
  ```json
  {
    "type": "object",
    "properties": {
      "id": { "type": "string" },
      "message": { "type": "string" }
    }
  }
  ```
  let's register it in the *schema-registry*
  
  ```shell
  curl -i -X POST  localhost:8085/subjects/message-value/versions -H "Content-Type: application/vnd.schemaregistry.v1+json" \
  --data '{"schemaType":"JSON", "schema":"{\"type\":\"object\",\"properties\":{\"id\":{\"type\":\"string\"},\"message\":{\"type\":\"string\"}}}"}'
  ```
  This should return schema id
  e.g.
  
  ```json
  {"id":1}
  ```

4. Pass message to *message* topic

  Now we need to publish following content on a topic *message* 
  ```
  {"id":"a", "message": "b"}
  ```
  
  using *kafka-json-schema-console-producer* shipped in schema-registry container.
  
  
  ```shell
  docker exec schema-registry  sh -c 'echo "{\"id\":\"a\", \"message\": \"b\"}" | /bin/kafka-json-schema-console-producer --bootstrap-server broker:9092  --property schema.registry.url=http://localhost:8085 --topic message --property value.schema.id=1'
  ```
  
> [!TIP]
> Alternatively you can use akhq web ui (however you need to select correct schema for value)


> [!NOTE]
> We can't use a regular console producer since it will not attach the schema id 
> in a message payload which is required by connector in order to recognize message type

5. check is data is stored in sql database *my_messages* in table messages


```shell
docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -d my_messages -U SA -P Hard2Guess -Q "select * from message"'
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

### check connector *kafka_to_sql_server* config

```shell 
curl -i localhost:8083/connectors/kafka_to_sql_server
```

### delete connectora *kafka_to_sql_server*

```shell 
curl -i -X DELETE localhost:8083/connectors/kafka_to_sql_server
```

### add connector stored in *kafka_to_sql_server.json*

```shell
curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@kafka_to_sql_server.json"
```

### delete messages in message table

```shell
docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -d my_messages -U SA -P Hard2Guess -Q "delete from message where 1 = 1"'
```

## Links

- https://docs.confluent.io/cloud/current/connectors/cc-microsoft-sql-server-sink.html
- https://stackoverflow.com/questions/68200588/kafka-connect-jdbc-source-connector-jdbc-sink-connector-mssql-sql-server
- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/
- https://stackoverflow.com/questions/76584938/how-to-handle-nested-arrays-of-struct-in-kafka-jdbc-sink-connector
- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained
