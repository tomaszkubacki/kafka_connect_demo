# Kafka Connect Demo

This repository contains set of step-by-step recipes allowing to run and test various Kafka Connect scenarios, 
using docker and command line interface.

## Prerequisites

1) Install Docker and docker compose

    > [!TIP]
    > In case of Ubuntu install docker from snap it has docker compose built in or install docker-compose-v2

2) Download JDBC Connector (Source and Sink) https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc
and unpack jars into *data* directory in this repo (jars will be mounted as volume for kafka-connect)

3) Download the newest *schema_wrapping* jar (in releases) and put it into *data* directory (just like jdbc jars) 
from [here](https://github.com/tomaszkubacki?tab=packages&repo_name=schema_wrapping)


## Run all required docker containers

Start all required containers at once

```shell
docker compose up -d
```

## Clean up

Remove all containers

```shell
docker compose down
```

## Demo scenarios

Scenarios assume all docker services are running.

- [kafka to SqlServer using JdbcSinkConnector](kafka_to_sql_server/kafka_to_sql_server.md)

- [kafka schemaless data from kafka topic to PostgreSQL using JdbcSinkConnector](kafka_to_postgresql/kafka_to_postgres.md)

- [kafka schemaless data from kafka topic to SqlServer using JdbcSinkConnector](kafka_to_sql_server_shemaless/kafka_to_sql_server_schemaless.md)

## Helper commands

### List connector plugins

```shell
curl http://localhost:8083/connector-plugins | jq
```

### List connectors 

```shell
curl http://localhost:8083/connectors
```

### Clean up docker 
```shell
docker compose down
```

