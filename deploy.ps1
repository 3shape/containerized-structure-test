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
  Write-Host "Rebasing image to produce 2016/1607 variant"
  npm install -g rebase-docker-image
  rebase-docker-image `
    "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
    -s mcr.microsoft.com/windows/nanoserver:1809 `
    -t "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1607" `
    -b mcr.microsoft.com/windows/nanoserver:sac2016

  Write-Host "Rebasing image to produce 1709 variant"
  rebase-docker-image `
    "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
    -s mcr.microsoft.com/windows/nanoserver:1809 `
    -t "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1709" `
    -b mcr.microsoft.com/windows/nanoserver:1709

  Write-Host "Rebasing image to produce 1803 variant"
  rebase-docker-image `
    "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
    -s mcr.microsoft.com/windows/nanoserver:1809 `
    -t "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1803" `
    -b mcr.microsoft.com/windows/nanoserver:1803

  Write-Host "Rebasing image to produce 1903 variant"
  rebase-docker-image `
    "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME" `
    -s mcr.microsoft.com/windows/nanoserver:1809 `
    -t "${image}:$os-$env:ARCH-$env:APPVEYOR_REPO_TAG_NAME-1903" `
    -b mcr.microsoft.com/windows/nanoserver:1903
} else {
  # Linux
  if ($env:ARCH -eq "amd64") {
    # The last in the build matrix
    docker -D manifest create "$($image):$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1607" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1709" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1803" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1903"
    docker manifest push "$($image):$env:APPVEYOR_REPO_TAG_NAME"

    Write-Host "Pushing manifest $($image):latest"
    docker -D manifest create "$($image):latest" `
      "$($image):linux-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1607" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1709" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1803" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME" `
      "$($image):windows-amd64-$env:APPVEYOR_REPO_TAG_NAME-1903"
    docker manifest push "$($image):latest"
  }
}
