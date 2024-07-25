# Kafka Connect Demo

## Prerequesties

1) Install docker and docker compose
(In case of Ubuntu install docker from snap it has docker compose built in)
2) Downlaod JDBC Connector (Source and Sink) https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc
and unpack jars into *data* directory in this repo (jars will be mounted as volume for kafka-connect)

## Run all required docker containers

If you compose up skhq, they will get up all because of dependecy relation in compose file
```
docker compose up -d akhq
```

## Demo scenarios

Sceanarios assume all docker services  are running.


### Stream event to MS SQL Server table

1. Create table in MS SQL using message.sql definition using any db browser
2. Add Kafka connector stored in *kafka_to_sql_server.json*
```bash
curl -i -X POST localhost:8083/connectors \
 -H "Content-Type: application/json"  \
 --data-binary "@kafka_to_sql_server.json"
```
3. Using akhq UI add message-schema.json in schema registry under message-value subject 
4. Using akhq UI add message to *message* topic with any string key and value according to schema e.g.
```json
{"id":"id", "message": "example"}
```

5. check is data is stored in sql database *my_logz* in table messages using any db browser

## Helper commands

### List connector plugins

```
curl http://localhost:8083/connector-plugins | jq
```

### List connectors 

```
curl http://localhost:8083/connectors
```

```bash

docker compose up -d akhq
```

### List active connectors

```bash
curl -i -X GET localhost:8083/connectors 
```

### Add connector definition

## Delete connector
```bash 
curl -i -X DELETE localhost:8083/connectors/kafka_to_sql_server
```

### List schemas
```bash
curl -i -X GET localhost:8085/subjects
```

### Register new schema
```bash
curl -i -X POST localhost:8085/subjects/testing \
 -H "Content-Type: application/json"  \
 --data-binary "@message-schema.json"
```
# Links

- https://docs.confluent.io/cloud/current/connectors/cc-microsoft-sql-server-sink.html
- https://stackoverflow.com/questions/68200588/kafka-connect-jdbc-source-connector-jdbc-sink-connector-mssql-sql-server
- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/
- https://stackoverflow.com/questions/76584938/how-to-handle-nested-arrays-of-struct-in-kafka-jdbc-sink-connector


### Worklog

### 20/07/2024 
Added basic docker compose with prerequesties in docker mode

#### Next steps
- add kafka-connect and ms sql to docker compose
- try to run kafka-connect in the first sceneario


