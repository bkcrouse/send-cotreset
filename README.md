# Send-CoTReset.ps1

A powershell script to interrupt WinTAK/ATAK devices and reset them to send Cursor on Target (CoT) message traffic.

This script will generate a cot  message of a specific cot type that causes ATAK/WinTAK clients
to stop using protobuf and use cot on the SA network.

The cot type sent is 'y-a-f-A' which 'should' not render a point on the map. Only tested with WinTAK/ATAK devices and not other CoT mapping applications.

### example
```powershell
  PS C:\> Send-CotReset.ps1

```

Sends a CoT message to the default SA port fo 239.2.3.1 port 6969

This has to be sent about once per minute to continually keep the SA network from reverting back to protobuf. It is recommended to add to a ```cron``` or ```scheduled task```.


