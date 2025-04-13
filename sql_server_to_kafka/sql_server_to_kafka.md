## Stream events from MS SQL Server table to Kafka

In this scenario we will stream kafka messages from  Ms Sql Server table  to Kafka using JdbcSourceConnector.


1. Create database *kafka_source* and *kafka_source* table

    create a database 
    ```shell
    docker exec sql-server sh -c '/opt/mssql-tools18/bin/sqlcmd -C -U SA -P Hard2Guess -Q "create database kafka_source"'
    ```
    
    copy *kafka_source.sql* into Sql Server container
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

    docker exec -it sql-server sh -c "/opt/mssql-tools18/bin/sqlcmd -C -d kafka_source -U SA -P Hard2Guess"

insert into dbo.kafka_source(message_content,message_key, kafka_topic) values ('{"a": 898}', '1234567890', 'test_topic')

2. Add Kafka connector stored in *sql_server_to_kafka.json*

    register the connector itself. Definition is in the *sql_server_to_kafka.json* file
    ```shell
    curl -i -X POST localhost:8083/connectors  -H "Content-Type: application/json" --data-binary "@sql_server_to_kafka.json"
    ```

#### delete connector  *kafka_to_sql_server_schemaless*

```shell 
curl -i -X DELETE localhost:8083/connectors/jdbc_source_sqlserver
```




