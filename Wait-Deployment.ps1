function Wait-Deployment
{
    <#
    .Synopsis
        Waits for a deployment to complete
    .Description
        Waits for a deployment to Azure to complete
    .Example
        Wait-Deployment -ServiceName "start-automating"
    .Link
        Add-Deployment
    .Link
        Get-Deployment
    .Link
        Import-Deployment
    .Link
        Publish-Deployment
    .Link
        Remove-Deployment
    #>
    [OutputType([Nullable])]
    param(
    # The name of the Azure service
    [Parameter(Mandatory=$true,ParameterSetName='WaitForAzureDeployment',ValueFromPipelineByPropertyName=$true)]
    [string]
    $ServiceName,

    # The slot that is being deployed.  Either Staging or Production.
    [Parameter(ParameterSetName='WaitForAzureDeployment',ValueFromPipelineByPropertyName=$true)]
    [ValidateSet("Staging","Production")]
    [string]
    $Slot = "Staging"
    )
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'WaitForAzureDeployment') {
            $progressId = Get-Random 
            $perc = 0 
            $notReady = $true
            #region Wait for the role to become available
            while ($notReady) {
                $ProgressPreference = 'silentlycontinue'
                $notReady = (Get-AzureDeployment -ServiceName $ServiceName -Slot $Slot).roleInstanceList | Where-Object {
                    $_.InstanceStatus -ne 'ReadyRole'
                }
                
                $ProgressPreference = 'continue'
                $null = $ProgressPreference
                $perc += 5
                if ($perc -gt 100) { 
                    $perc = 0 
                }
                Write-Progress "Waiting for Role to Start" " " -PercentComplete $perc -Id $progressId
                Start-Sleep -Seconds 1 
            }
            #endregion Wait for the role to become available
        }        
    }
} 
