create table dbo.kafka_sink
(
    id bigint  IDENTITY(1,1) NOT NULL,
    message_content varchar(max) not null,
    message_key     varchar(max),
    message_ts      bigint       not null,
    abc             varchar(max),
    kafka_offset    bigint       not null,
    kafka_partition int          not null,
    kafka_topic     varchar(900) not null,
    primary key (id)
)

