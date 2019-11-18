# Summary

Containerized wrapper for [github.com/GoogleContainerTools/container-structure-test](https://github.com/GoogleContainerTools/container-structure-test).

Purpose is to make it easy to use Docker sockets to grab local images for testing.

## Example (using PowerShell)

- Get an image to test and the container version of this Dockerfile.

```powershell
docker pull ubuntu:latest
docker pull 3shape/containerized-structure-test
```

- Map your local docker daemon into the structure container and run tests against ubuntu:latest. In this example the structure tests are defined in a file called gc-config.yml that resides in the same directory as where the command is being executed.


### Testing with Linux

```powershell
docker run --rm -v ${PWD}:/configs -v /var/run/docker.sock:/var/run/docker.sock 3shape/containerized-structure-test test -c /configs/gc-linux-config.yml -i ubuntu:latest
```

### Testing with Windows

```powershell
docker run --rm -v ${PWD}:C:/configs -v \\.\pipe\docker_engine:\\.\pipe\docker_engine 3shape/containerized-structure-test test -c /configs/gc-windows-config.yml -i mcr.microsoft.com/windows/nanoserver:1809
```
