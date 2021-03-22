[xml]$LastScanResult = (get-childitem "C:\Program Files\Bitdefender\Endpoint Security\logs\system" -Recurse -Filter "*.xml" | Sort-Object -Property LastWriteTime | Select-Object -last 1 | get-content -raw)
 
if (!$LastScanResult) {
    write-host "Unhealthy - could not retrieve last scan result."
    exit 1
}
$ScanResults = [PSCustomObject]@{
    Scanned       = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.Scanned | measure-object -sum).Sum
    Infected      = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.Infected | measure-object -sum).Sum
    suspicious    = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.suspicious | measure-object -sum).Sum
    Disinfected   = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.Disinfected | measure-object -sum).Sum
    Deleted       = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.deleted | measure-object -sum).Sum
    Moved         = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.moved | measure-object -sum).Sum
    Moved_reboot  = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.moved_reboot | measure-object -sum).Sum
    Delete_reboot = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.delete_reboot | measure-object -sum).Sum
    Renamed       = ($LastScanResult.ScanSession.ScanSummary.TypeSummary.renamed | measure-object -sum).Sum
}
 
$Alertresult = $ScanResults | Select-Object -Property * -ExcludeProperty Scanned | Where-Object { $_.psobject.properties.value -gt 0 }
 
if ($Alertresult) {
    write-host "Unhealthy - Last scan found issues"
    $ScanResults
}
else {
    write-host "Healthy - Last scan found no issues."
    $ScanResults
}