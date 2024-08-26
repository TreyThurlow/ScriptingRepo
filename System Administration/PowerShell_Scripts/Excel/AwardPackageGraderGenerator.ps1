<#
.SYNOPSIS
Generates an Excel spreadsheet with packages, statements, and average grades.

.DESCRIPTION
This script prompts the user for the number of packages and the number of statements per package. It then creates an Excel workbook containing a worksheet with the specified packages, statement numbers, and placeholders for grades. For each package, the script creates merged cells for the package name, adds headers for statement numbers and grades, and calculates the average grade for the statements within that package. The created workbook is then saved to the user's home directory.

This script was created to automatically create a spreadsheet to grade Air Force award packages.
#>

# Prompt for the number of packages
$packageCount = Read-Host "Enter the number of packages"

# Prompt for the number of statements
$statementCount = Read-Host "Enter the number of statements"

# Create a new Excel application object
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false  # Optional: Set to $true if you want Excel to be visible

# Add a new workbook
$workbook = $excel.Workbooks.Add()

# Add a worksheet for the packages
$worksheet = $workbook.Worksheets.Item(1)
$worksheet.Name = "Packages"

# Set initial row index
$rowIndex = 1

# Loop through each package
for ($i = 1; $i -le $packageCount; $i++) {
    $packageStartColumn = ($i - 1) * 3 + 1
    
    # Add merged cells for package name and center them
    $packageRange = $worksheet.Range($worksheet.Cells.Item($rowIndex, $packageStartColumn), $worksheet.Cells.Item($rowIndex, $packageStartColumn + 1))
    $packageRange.Merge() | Out-Null
    $packageRange.HorizontalAlignment = -4108  # Center alignment
    $packageRange.Font.Bold = $true
    $packageRange.Value = "Package $i"
    
    # Add headers for statements and grades and center them
    $worksheet.Cells.Item($rowIndex + 1, $packageStartColumn).Value = "Statement Number"
    $worksheet.Cells.Item($rowIndex + 1, $packageStartColumn + 1).Value = "Grade"
    $headerRange = $worksheet.Range($worksheet.Cells.Item($rowIndex + 1, $packageStartColumn), $worksheet.Cells.Item($rowIndex + 1, $packageStartColumn + 1))
    $headerRange.HorizontalAlignment = -4108  # Center alignment
    $headerRange.Font.Bold = $true
    
    # Add statement numbers
    for ($j = 1; $j -le $statementCount; $j++) {
        $worksheet.Cells.Item($rowIndex + $j + 1, $packageStartColumn).Value = $j
    }
    
    # Add 'Average' label and center it
    $worksheet.Cells.Item($rowIndex + $statementCount + 2, $packageStartColumn).Value = "Average"
    $averageRange = $worksheet.Range($worksheet.Cells.Item($rowIndex + $statementCount + 2, $packageStartColumn), $worksheet.Cells.Item($rowIndex + $statementCount + 2, $packageStartColumn + 1))
    $averageRange.HorizontalAlignment = -4108  # Center alignment
    $averageRange.Font.Bold = $true
    
    # Add formula to calculate average grade
    $startCell = $worksheet.Cells.Item($rowIndex + 2, $packageStartColumn + 1).Address()
    $endCell = $worksheet.Cells.Item($rowIndex + $statementCount + 1, $packageStartColumn + 1).Address()
    $averageFormula = "=AVERAGE($($startCell):$($endCell))"
    $worksheet.Cells.Item($rowIndex + $statementCount + 2, $packageStartColumn + 1).Formula = $averageFormula
}

# Auto-fit columns
$worksheet.Columns.AutoFit() | Out-Null

# Save the workbook
$excelFilePath = "$HOME\File.xlsx"
$workbook.SaveAs($excelFilePath)

# Close the workbook and Excel application
$workbook.Close($false)
$excel.Quit()

# Release COM objects
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()

Write-Host "Excel spreadsheet created successfully at: $excelFilePath"
