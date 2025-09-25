# Stream events from MS SQL Server table to Kafka

In this scenario we will stream Kafka messages from Ms Sql Server table to Kafka using JdbcSourceConnector.

First we create [kafka_source.sql](kafka_source.sql) table. Next we define [sql_server_to_kafka.json](sql_server_to_kafka.json)  
connector. Connector is querying db every 10 seconds.

For any new record from that table, data stored in _message_content_ column
will be sent to the topic defined in _kafka_topic_ column.

> [!NOTE]
> For topic selection we are using custom _SelectTopicTransform_
> _SelectTopicTransform_ source code can be found [here](https://github.com/tomaszkubacki/schema_wrapping/blob/main/src/main/java/net/tk/kafka/connect/transforms/SelectTopicTransform.java)

### Step-by-step instruction

1. Create database _kafka_source_ and _kafka_source_ table

   create a database

   ```shell
   docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -U SA -P Hard2Guess -Q "create database kafka_source"'
   ```

   copy _kafka_source.sql_ into Sql Server container

   ```shell
   docker cp kafka_source.sql sql-server:/tmp/kafka_source.sql
   ```

   create table defined in kafka_sink.sql

   ```shell
   docker exec sql-server sh -c "/opt/mssql-tools18/bin/sqlcmd -C -d kafka_source -U SA -P Hard2Guess -i /tmp/kafka_source.sql"
   ```

   query table to see if config is working fine (you should see empty table result)

   ```shell
   docker exec sql-server sh -c "/opt/mssql-tools18/bin/sqlcmd -C -d kafka_source -U SA -P Hard2Guess -Q 'select * from kafka_source'"
   ```

2. Add Kafka connector stored in _sql_server_to_kafka.json_

   register the connector itself. Definition is in the _sql_server_to_kafka.json_ file

   ```shell
   curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@sql_server_to_kafka.json"
   ```

3. Add record to _kafka_source_ table

   open sqlcmd cli tool in an interactive mode

   ```shell
   docker exec -it sql-server sh -c "/opt/mssql-tools18/bin/sqlcmd -C -d kafka_source -U SA -P Hard2Guess"
   ```

   ```shell
   insert into dbo.kafka_source(message_content,message_key, kafka_topic) values ('{"a": 343}', '1234567890', 'other_topic')
   ```

#### delete connector _kafka_to_sql_server_schemaless_

```shell
curl -i -X DELETE localhost:8083/connectors/jdbc_source_sqlserver
```
