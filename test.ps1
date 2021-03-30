using module "VolumeChange/VolumeChange.psm1"

echo "=="
Invoke-VolumeChangeInter 0.2

echo "=="
Invoke-VolumeChangeInter 0.2 $false

echo "=="
Invoke-VolumeChangeInter 0.1 $false @(1)

echo "=="
Invoke-VolumeChangeInter 0.2 $true

echo "=="
Invoke-VolumeChange conf.json

start-sleep 30
