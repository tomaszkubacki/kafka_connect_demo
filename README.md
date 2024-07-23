# Kafka Connect Demo

**_NOTE:_** This is work in progress - see worklog below

## Prerequesties

1) Install docker and docker compose
(In case of Ubuntu install docker from snap it has docker compose in built in)
2) Downlaod JDBC Connector (Source and Sink) https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc

## Run all required docker containers

If you compose up skhq, they will get up all because of dependecy relation in compose file
```
docker compose up -d akhq
```

### List connector plugins

```
curl http://localhost:8083/connector-plugins | jq
```


### List connectors 

```
curl http://localhost:8083/connectors
```


## Scenearios
1.  Stream event to MS SQL Server table


# Links

- https://docs.confluent.io/cloud/current/connectors/cc-microsoft-sql-server-sink.html
- https://stackoverflow.com/questions/68200588/kafka-connect-jdbc-source-connector-jdbc-sink-connector-mssql-sql-server

```bash
docker compose up -d akhq
```

### Add connector definition

```bash
curl -i -X POST localhost:8083/connectors \
 -H "Content-Type: application/json"  \
 --data-binary "@kafka_to_sql_server.json"
```

### Worklog

### 20/07/2024 
Added basic docker compose with prerequesties in docker mode

#### Next steps
- add kafka-connect and ms sql to docker compose
- try to run kafka-connect in the first sceneario


