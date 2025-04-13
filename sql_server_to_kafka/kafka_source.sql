create table dbo.kafka_source
(
    id bigint  IDENTITY(1,1) NOT NULL,
    message_content varchar(max) not null,
    message_key     varchar(max),
    kafka_topic     varchar(900) not null,
    primary key (id)
)

