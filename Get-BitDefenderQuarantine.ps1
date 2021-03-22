$SQLLite = Get-ChildItem 'C:\Programdata\System.Data.SQLite.dll' -ErrorAction SilentlyContinue
If (!$SQLLite) {
    Invoke-WebRequest -Uri "https://github.com/springpoint/PublicFileHosting/raw/main/System.Data.SQLite.dll" -UseBasicParsing -OutFile "C:\Programdata\System.Data.SQLite.dll"
}
 
try {
    Add-Type -Path "C:\Programdata\System.Data.SQLite.dll"
} catch {
    Write-Host "Could not load database components."
    exit 1
}
$con = New-Object -TypeName System.Data.SQLite.SQLiteConnection
$con.ConnectionString = "Data Source=C:\Program Files\Bitdefender\Endpoint Security\Quarantine\cache.db"
$con.Open()
$sql = $con.CreateCommand()
$sql.CommandText = "select * from entries"
$adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
$data = New-Object System.Data.DataSet
[void]$adapter.Fill($data)
$sql.Dispose()
$con.Close()
 
$CurrentQ = foreach ($row in $Data.Tables.rows) {
    [PSCustomObject]@{
        Path               = $row.path
        Threat             = $row.threat
        Size               = $row.Size
        'Quarantined On'   = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($row.quartime))
        'Last accessed On' = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($row.acctime))
        'Last Modified On' = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($row.modtime))
    }
}
 
if ($CurrentQ) {
    Write-Host $CurrentQ
} else {
    Write-Host "Healthy - No infections found."
}