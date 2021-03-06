function Connect-EC2
{
    <#
    .Synopsis
        Connects to an EC2 instance 
    .Description
        Connects to an EC2 instance with Remote Desktop
    .Example
        Get-EC2 -Name MyServer | 
            Connect-EC2
    .Link
        Get-EC2    
    #>
    [CmdletBinding(SupportsShouldProcess='true', ConfirmImpact='High')]
    [OutputType([string])]
    param(
    # The ID of the EC2 Instance 
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
    [string]
    $InstanceId
    )
    
    process {
        $ec2 = Get-EC2 -InstanceId $instanceId
        $ec2Cred = $ec2 | Get-EC2InstancePassword -AsCredential
        
        $rdpFile = 
            New-RDPFile -ComputerName $ec2.PublicDnsName -Credential $ec2Cred 
        if (-not (Test-Path "$home\EC2RDP")) {
            $null = New-Item -ItemType Directory -Path "$home\EC2RDP"
        }
        $rdpFileName =  "$home\EC2RDP\$($ec2.PublicDnsName)_$(Get-Random).rdp"
        [io.file]::WriteAllText($rdpfilename,$rdpFile.trim())
            
        $ec2 | 
            Open-EC2Port -Range 3389 -ErrorAction SilentlyContinue
        
        Invoke-Item $rdpFileName
        
        Start-Sleep -Milliseconds 500

        Remove-Item -Path $rdpFileName
    }
} 
