# Fledge IOT Framework running in Docker

This is the fastest way to get the Fledge IOT Framework up and running for evaluation.


### To build the container
```
docker build -t fledge:1.8.0 .
```

### To run the container detached (in the background)
```
docker run -d --name -p 8081:8081 fledge fledge:1.8.0
```

### To view the container logs
```
docker logs fledge -f
```


## Docker Hub Image

This image is also available prebuilt. You can pull it and run it using the following commands.

```
docker pull robraesemann/fledge

docker run -d --name -p 8081:8081 fledge fledge:latest
docker logs fledge -f

```