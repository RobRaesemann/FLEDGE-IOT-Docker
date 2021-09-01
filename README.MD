# Fledge IOT Framework running in Docker

This is the fastest way to get the Fledge IOT Framework up and running for evaluation.

See the FLEDGE GUI Docker container at:
https://hub.docker.com/repository/docker/robraesemann/fledge-gui


## Docker-Compose file makes it easy to test FLEDGE, FLEDGE-GUI, and Kafka North Plugin

The docker-compose file will pull everything that you need from Docker Hub. 

You can use Kafka Tool to view the data sent to Kafka
https://www.kafkatool.com/

```
docker-compose up -d
```




### To build the container
```
docker build -t fledge .
```

### To run the container detached (in the background)
```
docker run -d --name fledge -p 8081:8081 -p 1995:1995 -p 8080:8080 fledge
```

### To view the container logs
```
docker logs fledge -f
```

### To enter the container command line
```
docker exec -it fledge /bin/bash
```


## Docker Hub Image

This image is also available prebuilt. You can pull it and run it using the following commands.

```
docker pull robraesemann/fledge

docker run -d --name fledge -p 8081:8081 -p 1995:1995 -p 8080:8080 robraesemann/fledge

docker logs -f fledge 
```