<#
.SYNOPSIS
    Removes WMI subscriptions on a remote computer.

.DESCRIPTION
    This script prompts the user to enter the IP address of a remote computer and the contents of the quotes in the __RELPATH line. It then uses PowerShell remoting to connect to the remote computer and remove WMI subscriptions, including event filters, event consumers, and filter-to-consumer bindings.

.EXAMPLE
    PS C:\> .\Kill-WMIEvents.ps1
    Enter the IP Address of the computer: 192.168.1.10
    Enter the contents of the Quotes in the __RELPATH line: Group_Policy_Status Filter

    This example removes WMI subscriptions related to 'Group_Policy_Status Filter' on the remote computer with IP address 192.168.1.10.
#>


$IPAddress = Read-Host "Enter the IP Address of the computer"

New-PSSession -ComputerName $IPAddress -Credential $Creds

# List all WMI subscriptions on the remote computer
$subscriptions = Get-WmiObject -Namespace "root\subscription" -Class "__EventFilter" -ComputerName $IPAddress

# Display the subscriptions to the user
$subscriptions | ForEach-Object {
    Write-Host "Name: $($_.Name) - Query: $($_.Query)"
}

# Prompt the user to enter the name of the subscription to delete
$subscriptionName = Read-Host "Enter the name of the WMI subscription to delete"

# Find the subscription to delete
$subscriptionToDelete = $subscriptions | Where-Object { $_.Name -eq $subscriptionName }

if ($subscriptionToDelete) {
    # Delete the EventFilter
    $subscriptionToDelete.Delete()

    # Find and delete the corresponding FilterToConsumerBinding
    $bindings = Get-WmiObject -Namespace "root\subscription" -Class "__FilterToConsumerBinding" -ComputerName $IPAddress
    $bindingToDelete = $bindings | Where-Object { $_.Filter -eq $subscriptionToDelete.__RELPATH }
    if ($bindingToDelete) {
        $bindingToDelete.Delete()
        Write-Host "WMI subscription '$subscriptionName' has been deleted."
    } else {
        Write-Host "No corresponding FilterToConsumerBinding found for '$subscriptionName'."
    }
} else {
    Write-Host "No WMI subscription found with the name '$subscriptionName'."
}