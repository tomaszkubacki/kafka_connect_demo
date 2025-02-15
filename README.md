# Kafka Connect Demo

This repository contains set of ready recipies allowing to run and test various Kafka Connect scenarios, 
with step by step procedures using docker and command cline interface.

## Prerequisites

1) Install Docker and docker compose

> [!TIP]
> In case of Ubuntu install docker from snap it has docker compose built in or install docker-compose-v2

2) Downlaod JDBC Connector (Source and Sink) https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc
and unpack jars into *data* directory in this repo (jars will be mounted as volume for kafka-connect)

## Run all required docker containers

Start all required containers at once by invoking 

```
docker compose up -d
```

## Clean up

After finishing you can remove all containers by invoking

```
docker compose down
```

## Demo scenarios

Scenarios assume all docker services are running.

- [Stream data from kafka topic to SqlServer using JdbcSinkConnector](kafka_to_sql_server)



## Helper commands

### List connector plugins

```
curl http://localhost:8083/connector-plugins | jq
```

### List connectors 

```shell
curl http://localhost:8083/connectors
```

### List active connectors

```shell
curl -i -X GET localhost:8083/connectors
```

### Clean up docker 
```shell
docker compose down
```
# Links

- https://docs.confluent.io/cloud/current/connectors/cc-microsoft-sql-server-sink.html
- https://stackoverflow.com/questions/68200588/kafka-connect-jdbc-source-connector-jdbc-sink-connector-mssql-sql-server
- https://www.confluent.io/blog/kafka-connect-deep-dive-converters-serialization-explained/
- https://stackoverflow.com/questions/76584938/how-to-handle-nested-arrays-of-struct-in-kafka-jdbc-sink-connector

### Worklog

### 15/02/2025
Rework SqlServer streaming to be more precise cli only tutorial

### 05/08/2024
Tweak README, correct compose dependecy

### 25/07/2024
Added working example and README for streaming from Kafka to Sql Server scenerio

#### next steps
- show postgres source and sink connector

### 20/07/2024 
Added basic docker compose with prerequesties in docker mode

#### Next steps
- add kafka-connect and ms sql to docker compose
- try to run kafka-connect in the first sceneario

