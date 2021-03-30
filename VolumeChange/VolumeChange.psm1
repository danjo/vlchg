using namespace System.Xml

function Invoke-VolumeChange() {
  param(
    [string]$confpath
  )

  $now = Get-Date -Format "HH:mm"
  Write-Host $now

  $jstr = get-content -raw $confpath
  $jobj = ConvertFrom-Json $jstr
  $vlchg = $jobj.vlchg
  foreach ($elem in $vlchg) {
    $range = $elem.range
    if ( $now -ge $range[0] -and $now -le $range[1] ) {
      $vol = [single]($elem.vol / 100)
      $toast = $elem.toast
      $toastparam = $elem.toastparam

      Invoke-VolumeChangeInter $vol $toast $toastparam
      break
    }
  }
}


function Invoke-VolumeChangeInter() {
  param(
    [single]$vol,
    [bool]$toast,
    $toastparam
  )

  $ret = change $vol

  if ($ret -ne $vol -and $toast -eq $true) {
    Write-Host "toast"
    toast "VolumeChange" "volume changed $ret -> $vol"
  }
}


# http://asaconsultant.blogspot.com/2014/05/toying-with-audio-in-powershell.html
function change([single]$s) {

  Add-Type -TypeDefinition @'

using System.Runtime.InteropServices;
[Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioEndpointVolume {
  // f(), g(), ... are unused COM method slots. Define these if you care
  int f(); int g(); int h(); int i();
  int SetMasterVolumeLevelScalar(float fLevel, System.Guid pguidEventContext);
  int j();
  int GetMasterVolumeLevelScalar(out float pfLevel);
  int k(); int l(); int m(); int n();
  int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, System.Guid pguidEventContext);
  int GetMute(out bool pbMute);
}
[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
  int Activate(ref System.Guid id, int clsCtx, int activationParams, out IAudioEndpointVolume aev);
}
[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
  int f(); // Unused
  int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice endpoint);
}
[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorComObject { }
public class Audio {
  static IAudioEndpointVolume Vol() {
    var enumerator = new MMDeviceEnumeratorComObject() as IMMDeviceEnumerator;
    IMMDevice dev = null;
    Marshal.ThrowExceptionForHR(enumerator.GetDefaultAudioEndpoint(/*eRender*/ 0, /*eMultimedia*/ 1, out dev));
    IAudioEndpointVolume epv = null;
    var epvid = typeof(IAudioEndpointVolume).GUID;
    Marshal.ThrowExceptionForHR(dev.Activate(ref epvid, /*CLSCTX_ALL*/ 23, 0, out epv));
    return epv;
  }
  public static float Volume {
    get {float v = -1; Marshal.ThrowExceptionForHR(Vol().GetMasterVolumeLevelScalar(out v)); return v;}
    set {Marshal.ThrowExceptionForHR(Vol().SetMasterVolumeLevelScalar(value, System.Guid.Empty));}
  }
  public static bool Mute {
    get { bool mute; Marshal.ThrowExceptionForHR(Vol().GetMute(out mute)); return mute; }
    set { Marshal.ThrowExceptionForHR(Vol().SetMute(value, System.Guid.Empty)); }
  }
}

'@

  $v1 = [audio]::Volume
  $v2 = $s
  write-host "now: $v1, to: $v2"
  # Write-Host $v1.GetType()
  # Write-Host $v2.GetType()

  # if ( $v1 -eq $v2 ) {
  if ( [Math]::Abs($v1 - $v2) -le [single]0.01 ) {
    write-host "bye"
    return $v2
  }

  [audio]::Volume = $v2
  return $v1
}



# https://steemit.com/powershell/@esoso/fun-with-toast-notifications-in-powershell
Function toast {

  [CmdletBinding()]
  PARAM (
    [Parameter(Mandatory = $true)][String] $title,
    [Parameter(Mandatory = $true)][String] $message
  )

  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
  [Windows.UI.Notifications.ToastNotification, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
  [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

  $app_id = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
  $content = @"
<?xml version="1.0" encoding="utf-8"?>
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$($title)</text>
            <text>$($message)</text>
        </binding>
    </visual>
</toast>
"@
  $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
  $xml.LoadXml($content)
  $toast = New-Object Windows.UI.Notifications.ToastNotification $xml
  [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($app_id).Show($toast)

  #             <image placement="appLogoOverride" src="hoge.png"/>
}



Export-ModuleMember -Function Invoke-VolumeChange, Invoke-VolumeChangeInter
