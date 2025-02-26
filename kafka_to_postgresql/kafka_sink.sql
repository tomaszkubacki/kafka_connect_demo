create table "kafka_sink"
(
    id  bigserial constraint order_pk primary key,
    topic_name text,
    content text
);

alter table "kafka_sink"
    owner to docker;


