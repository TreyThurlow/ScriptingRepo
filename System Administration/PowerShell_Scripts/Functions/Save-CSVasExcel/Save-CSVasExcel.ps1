<#
.SYNOPSIS
Converts a CSV file to an Excel file (.xlsx) format.

.DESCRIPTION
This function takes a CSV file as input and converts it into an Excel workbook (.xlsx). It opens the specified CSV file in Excel, adjusts the column widths to fit the content, and saves the file with the same base name as the original CSV but with an .xlsx extension. If a file with the same name already exists, it appends a numeric suffix to the new file name to ensure it is unique. The function handles the release of COM objects to prevent memory leaks.

.PARAMETER CSVFile
The path to the CSV file to be converted. If a path is not provided, the function will throw an error.

.EXAMPLE
Save-CSVasExcel -CSVFile "C:\path\to\your\file.csv"
This example converts the specified CSV file located at "C:\path\to\your\file.csv" into an Excel file and saves it in the same directory.

#>
function Save-CSVasExcel {
    param (
        [string]$CSVFile = $(Throw 'No file provided.')
    )
    
    BEGIN {
        function Resolve-FullPath ([string]$Path) {    
            if ( -not ([System.IO.Path]::IsPathRooted($Path)) ) {
                # $Path = Join-Path (Get-Location) $Path
                $Path = "$PWD\$Path"
            }
            [IO.Path]::GetFullPath($Path)
        }

        function Release-Ref ($ref) {
            ([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$ref) -gt 0)
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
        }
        
        $CSVFile = Resolve-FullPath $CSVFile
        $xl = New-Object -ComObject Excel.Application
    }

    PROCESS {
        $wb = $xl.workbooks.open($CSVFile)
        $xlOut = $CSVFile -replace '\.csv$', '.xlsx'
        
        # can comment out this part if you don't care to have the columns autosized
        $ws = $wb.Worksheets.Item(1)
        $range = $ws.UsedRange 
        [void]$range.EntireColumn.Autofit()

        $num = 1
        $dir = Split-Path $xlOut
        $base = $(Split-Path $xlOut -Leaf) -replace '\.xlsx$'
        $nextname = $xlOut
        while (Test-Path $nextname) {
            $nextname = Join-Path $dir $($base + "-$num" + '.xlsx')
            $num++
        }

        $wb.SaveAs($nextname, 51)
    }

    END {
        $xl.Quit()
    
        $null = $ws, $wb, $xl | % {Release-Ref $_}

        # del $CSVFile
    }
}