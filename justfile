help:
    just -l

# list all running containers
containers:
    docker ps

# start all required docker container
dev:
    docker compose up -d

# stop and remove all required containers
dev_stop:
    docker compose down

# enter container cli
enter container:
    docker exec -it {{container}} bash


