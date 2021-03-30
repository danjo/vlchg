' module install required

Set s = CreateObject("WScript.Shell")
s.Run "powershell Invoke-VolumeChange conf.json", 0, True
