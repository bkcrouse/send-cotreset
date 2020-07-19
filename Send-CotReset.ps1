<#
.SYNOPSIS
  A powershell script to interrupt WinTAK/ATAK devices and reset them to send Cursor on Target (CoT) message traffic.
.DESCRIPTION
  This script will generate a cot  message of a specific cot type that causes ATAK/WinTAK clients
  to stop using protobuf and use cot on the SA network.

  .EXAMPLE
  PS C:\> Send-CotReset.ps1

  Sends a CoT message to the default SA port fo 239.2.3.1 port 6969
.INPUTS
  None
.OUTPUTS
.NOTES

 Author: Brian Crouse
 IWasBorn: 18 July 2020

#>
[cmdletbinding()]
param( 
  [ValidateNotNullOrEmpty()]
  [string]
  $Path = "239.2.3.1", 

  [ValidateRange(80,65535)]
  [int]
  $Port = 6969,

  [ValidateNotNullOrEmpty()]
  [string]
  $CotType = "y-a-f-A",

  [string]
  $CallSign = "fake-noproto" + $(get-random -minimum 1 -maximum 65535),

  [switch]
  $ShowCot

)

#
# CoT XML Template used for processing
#
[xml] $cot_xml = @"
<?xml version='1.0' standalone='yes'?>
<event how="m-s"
       opex="e-JEFX04"
       stale="2019-08-02T15:20:59.24Z"
       start="2019-08-02T15:18:59.24Z"
       time="2019-08-02T15:18:59.24Z"
       type="y-a-f-A"
       uid="fake-noproto"
       version="2.0">

  <point ce="0" hae="0" lat="0" le="0" lon="0" />
       
  <detail>
    <contact endpoint="10.3.2.1:4242:tcp" callsign="$CallSign" />
	  <__group name="Black" />
  </detail>

</event>
"@

function Send-UdpCot
{
      Param ([string] $Path,
      [int] $Port, 
      [string] $Message)

      $IP = [System.Net.Dns]::GetHostAddresses($Path) 
      $Address = [System.Net.IPAddress]::Parse($($IP | ? { $_.AddressFamily -eq 'InterNetwork' })) 
      $EndPoints = New-Object System.Net.IPEndPoint($Address, $Port) 
      $Socket = New-Object System.Net.Sockets.UDPClient 
      $EncodedText = [Text.Encoding]::ASCII.GetBytes($Message) 
      $SendMessage = $Socket.Send($EncodedText, $EncodedText.Length, $EndPoints) 
      $Socket.Close() 
} 

#cot time formats
$cotDateTimeStringFormat = "yyyy-MM-ddTHH:mm:ss.ffZ"
$uid = "$CallSign"


#
# Send CoT on SA channel to reset to CoT
#
  $now = (get-date).ToUniversalTime().ToString($cotDateTimeStringFormat)
  $stale = (get-date).AddMinutes(1).ToUniversalTime().ToString($cotDateTimeStringFormat)
  $debugTime = (get-date).AddMinutes(1).ToUniversalTime().ToString($cotDateTimeStringFormat)
  $start = $now
  ($cot_xml).event.stale = $stale
  ($cot_xml).event.start = $start
  ($cot_xml).event.time = $now
  ($cot_xml).event.uid = $CallSign
  ($cot_xml).event.type = $CotType
    
  if ( $ShowCot ) {
    Write-Output $($cot_xml.OuterXml)
  }
  
  try { 
    Send-UdpCot -Path $Path -Port $Port -Message $cot_xml.outerxml
  } catch {
    Write-Output -Message "Error sending udp CoT datagram to ipaddress: $path, port: $port"
  }
