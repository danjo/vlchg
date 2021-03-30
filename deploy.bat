set DIR=VolumeChange

robocopy /MIR /R:0 ^
	%DIR% ^
	%HOMEDRIVE%%HOMEPATH%\Documents\WindowsPowerShell\Modules\%DIR%
