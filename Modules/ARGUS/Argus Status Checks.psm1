Function Start-ArgusStatusChecks {
    $Year = Get-Date -Format "yyyy"
    $Month = (Get-Date -Format M).Split(" ")[0]
    $Name = Get-Date -Format "dd-MM"
    $Path = "\\SERVERNAME\PATH\TO\DAILYCHECKSLOCATION\$Year\$Month"
    $HTMLPath = "\\SERVERNAME\PATH\TO\DAILYCHECKSLOCATION\$Year\$Month"
    $ServerList = Get-Content "\\PATH\TO\COMPUTER_OR_SERVER\LIST"

    if (!(Test-Path $Path)) {mkdir $Path}

    if (!(Test-Path $HTMLPath)) {mkdir $HTMLPath}
    #Make a new folder if it doesn't exist

    Get-Content $ServerList | Invoke-ARGUSStatusCheck -Verbose | Export-Csv "$Path\$Name.csv" -NoTypeInformation
}