# escape=`
FROM golang:1.12-windowsservercore-1809 as build

ENV GOOS=windows `
    GOARCH=amd64 `
    CGO_ENABLED=0

RUN go get github.com/sirupsen/logrus; `
    go get github.com/GoogleContainerTools/container-structure-test/cmd/container-structure-test/app; `
    go build ./src/github.com/GoogleContainerTools/container-structure-test/cmd/container-structure-test

FROM mcr.microsoft.com/windows/nanoserver:1809

COPY --from=build c:/gopath/container-structure-test.exe ./container-structure-test.exe

ENTRYPOINT [ "C:/container-structure-test.exe" ]
