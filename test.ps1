$ErrorActionPreference = 'SilentlyContinue'

if ($env:ARCH -ne "amd64") {
  Write-Host "Arch $env:ARCH detected. Skip testing."
  exit 0
}

Write-Host Starting test

docker kill containertest-test
docker rm -f containertest-test

$ErrorActionPreference = 'Stop';

if ($IsWindows) {
  [System.Environment]::OSVersion.Version
  Get-CimInstance Win32_OperatingSystem
  Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
  docker pull mcr.microsoft.com/windows/nanoserver:1809
  docker run --name containertest-test --rm -v "${PWD}:C:/configs" -v \\.\pipe\docker_engine:\\.\pipe\docker_engine containertest test -c /configs/tests/gc-windows-config.yml -i mcr.microsoft.com/windows/nanoserver:1809
} else {
  docker pull ubuntu:18.04
  docker run --name containertest-test --rm -v "${PWD}:/configs" -v /var/run/docker.sock:/var/run/docker.sock containertest test -c /configs/tests/gc-linux-config.yml -i ubuntu:18.04
}
