# Summary

Containerized wrapper for https://github.com/GoogleContainerTools/container-structure-test.

Purpose is to make it easy to use Docker sockets to grab local images for testing.

## Example (using PowerShell)

1. Get an image to test and the container version of this Dockerfile.
```powershell
docker pull ubuntu:latest
docker pull rasmusjelsgaard/containerized-structure-test
```

2. Map your local docker daemon into the structure container and run tests against ubuntu:latest. In this example the structure tests are defined in a file called gc-config.yml that resides in the same directory as where the command is being executed.

```
docker run  -it -v ${PWD}:/configs -v /var/run/docker.sock:/var/run/docker.sock containerized-structure-test test -c /configs/gc-config.yml -i ubuntu:latest
```


