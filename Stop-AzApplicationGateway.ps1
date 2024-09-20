<# 
.DESCRIPTION
A Runbook example which stops an Azure Application Gateway in a specific Azure subscription
using a user-assigned managed identity.

.NOTES
Filename : Stop-AzApplicationGateway
Author   : Marian Anghel
Version  : 1.0
Date     : 09-September-2024
#>

Param (
    [Parameter(Mandatory = $true)] [ValidateNotNullOrEmpty()]
    [String] $AzureSubscriptionId,

    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $rgName,

    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]
    [String] $ApplicationGateway
)

try
{
    Write-Output "Logging in to Azure using Managed Identity..."
    $AzureContext = (Get-AzContext).Account
    if ($null -eq $AzureContext) {
        Connect-AzAccount -Identity
    }
    Set-AzContext -SubscriptionId $AzureSubscriptionId
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Output "AzureSubscriptionId: $AzureSubscriptionId"
Write-Output "Resource Group Name: $rgName"
Write-Output "Application Gateway: $ApplicationGateway"

$context = Get-AzContext
if ($context.Subscription.Id -ne $AzureSubscriptionId) {
    throw "Subscription context is not set correctly."
}

try
{
    $agw = Get-AzApplicationGateway -Name $ApplicationGateway -ResourceGroupName $rgName
    if ($null -eq $agw) {
        throw "Application Gateway '$ApplicationGateway' not found in Resource Group '$rgName'."
    }
    Stop-AzApplicationGateway -ApplicationGateway $agw
    Write-Output ("Successfully stopped Application Gateway: " + $ApplicationGateway)
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}
