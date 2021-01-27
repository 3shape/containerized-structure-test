# Credit to https://github.com/StefanScherer

$ErrorActionPreference = 'Stop'

if (! (Test-Path Env:\APPVEYOR_REPO_TAG_NAME)) {
  Write-Host "No version tag detected. Skip publishing."
  exit 0
}

Write-Host Starting deploy

$image = '3shape/containerized-structure-test'
$auth =[System.Text.Encoding]::UTF8.GetBytes("$($env:DOCKER_USER):$($env:DOCKER_PASS)")
$auth64 = [Convert]::ToBase64String($auth)

if (!(Test-Path ~/.docker)) { mkdir ~/.docker }

@"
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "$auth64"
    }
  },
  "experimental": "enabled"
}
"@ | Out-File -Encoding Ascii ~/.docker/config.json

$os = If ($isWindows) {'windows'} Else {'linux'}

docker tag containertest "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"
docker push "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME"

if ($isWindows) {
  Write-Host "Rebasing image to produce another OS variants"
  npm install -g rebase-docker-image
  npm list -g --depth=0

  Write-Host "Rebasing image to produce 1803 variant"
  rebase-docker-image `
    "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
    -s stefanscherer/nanoserver:1809 `
    -t "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1803" `
    -b stefanscherer/nanoserver:1803

  Write-Host "Rebasing image to produce 1903 variant"
  rebase-docker-image `
    "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
    -s stefanscherer/nanoserver:1809 `
    -t "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1903" `
    -b stefanscherer/nanoserver:1903

  Write-Host "Rebasing image to produce 2004 variant"
    rebase-docker-image `
      "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
      -s stefanscherer/nanoserver:1809 `
      -t "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-2004" `
      -b stefanscherer/nanoserver:2004
  
  if ($env:ARCH -eq "amd64") {
    # Create manifest on Windows image as it is slower then Linux
    Write-Host "Pushing manifest ${image}:$($env:APPVEYOR_REPO_TAG_NAME)"
    docker manifest create "${image}:$env:APPVEYOR_REPO_TAG_NAME" `
      "${image}:linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "${image}:windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1803" `
      "${image}:windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "${image}:windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1903" `
      "${image}:windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-2004"
    docker manifest push "${image}:$env:APPVEYOR_REPO_TAG_NAME"

    Write-Host "Pushing manifest ${image}:latest"
    docker manifest create "${image}:latest" `
      "${image}:linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "${image}:windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1803" `
      "${image}:windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "${image}:windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1903" `
      "${image}:windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-2004"
    docker manifest push "${image}:latest"
  }
}
