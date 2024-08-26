<#
.SYNOPSIS
    Imports ACAS .csv results and automates the creation of Pivot Tables to easily see ACAS results. This script requires the use of the ImportExcel Module.
.DESCRIPTION
    This script was built with the assumption of three different Tenable Nessus reports. 1 for Workstations, 1 for General Servers, and 1 more Domain Controllers. You will need to edit the variables to specify the paths to each file. 
.NOTES
Author: SSgt Trey Thurlow, NCOIC, NPES; JCA
#>

Import-Module ImportExcel

$Year = Get-Date -Format "yyyy"
$Month = Get-Date -Format "MMM yyyy"
$TodayDate = Get-Date -Format "dd MMM yyyy"
$RawACASScanFilePath = "\\server\folder1\Scans\ACAS" 

$WKSResults = "$RawACASScanFilePath\$Year\$Month\$TodayDate\wks.csv"
$DCResults = "$RawACASScanFilePath\$Year\$Month\$TodayDate\dc.csv"
$MSResults = "$RawACASScanFilePath\$Year\$Month\$TodayDate\mbr.csv"


$ReportPath = "SET\LOCATION\OF\FINAL\FILE"
$FileDate = Get-Date -Format "yyyy-MM-dd"
$ResultFile = $ReportPath + "ACAS Results Sorted" + "_" + $FileDate + ".xlsx"

Import-CSV $WKSResults | Export-Excel $ResultFile -WorksheetName "WKS Results" -Autosize
Import-Csv $DCResults | Export-Excel $ResultFile -WorksheetName "DC Results" -Autosize
Import-Csv $MSResults | Export-Excel $ResultFile -WorksheetName "MS Results" -Autosize

$excel = Open-ExcelPackage -Path $ResultFile -KillExcel

Add-PivotTable -ExcelPackage $excel -PivotRows "Plugin Name", "Plugin Output", "DNS Name" -SourceWorkSheet "WKS Results" -PivotTableName "WKS Results"
Add-PivotTable -ExcelPackage $excel -PivotRows "Plugin Name", "Plugin Output", "DNS Name" -SourceWorkSheet "DC Results" -PivotTableName "DC Results"
Add-PivotTable -ExcelPackage $excel -PivotRows "Plugin Name", "Plugin Output", "DNS Name" -SourceWorkSheet "MS Results" -PivotTableName "MS Results"

Close-ExcelPackage -ExcelPackage $excel -Show