# vlchg - VolumeChange

# Description

Change sound device's volume with or without toast notification. Expects use with task scheduler.

# Target Environments
Windows Powershell 5.x on Windows10 64bit.
* Not tested with Powershell Core (> 6.0).

# CLI Usage
    Invoke-VolumeChange [config filepath]

## how to run
### when module installed
    Invoke-VolumeChange conf.json

### when download release zip/repo
    cd /path/to/vlchg
    using module "VolumeChange/VolumeChange.psm1"
    Invoke-VolumeChange conf.json

# Config file format

JSON based text like below.

    {
      "vlchg": [
        {
          "range": [
            "06:00",
            "21:00"
          ],
          "vol": 54,
          "toast": false,
          "toastparam" : {}
        },
        {
          "range": [
    <snip>

- range:

  array of 2 strings, which values are times as 24-hour notation.

- vol:

  int, volume value. 0 to 100.

- toast:

  boolean, enable toast notification.

- toastparam:

  not used

# Run without display window

vlchg.vbs

- run Invoke-VolumeChange
- run without display window
- module install required

# Execute Periodically with Task Scheduler

vlchg.xml

- taskscheduler import sample
- run vlgch.vbs every 70 minits periodically
- need to update ageinst target environment:
  - UserId
  - Command
  - WorkingDirectory


# References

- [Controlling mute/unmute and the volume on you computer with powershell.](http://asaconsultant.blogspot.com/2014/05/toying-with-audio-in-powershell.html)
- [Fun with toast notifications in Powershell](https://steemit.com/powershell/@esoso/fun-with-toast-notifications-in-powershell)
