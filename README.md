# docker-murmur
Docker-murmur provides a mumble server (called murmur) inside a docker container.
Our implementation is different from most of the other Dockerfiles, as gRPC is enabled
by default during compile time.

### Building murmur

```
docker build -t zombi/murmur .
```

### Running murmur

```
docker compose up -d
```
