$ErrorActionPreference = 'Stop'

Write-Host Starting build

docker info
$os = If ($isWindows) {'windows'} Else {'linux'}
docker build --tag containertest --file "src/${os}.dockerfile" .
