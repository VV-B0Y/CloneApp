function Export-AzureADApp {
    <#
    .SYNOPSIS
    Export Azure AD App name & API permissions to an xml

    .DESCRIPTION
    Export Azure AD App name & API permissions to an xml

    This function outputs and xml, use that xml with Import-AzureADApp function to
    create a new app with the same API permissions

    .PARAMETER Name
    Name of the App to export
    use either Name or ObjectId, not both

    .PARAMETER ObjectId
    ObjectId of the app to export
    use either Name or ObjectId, not both

    .PARAMETER Path
    Path where the script will save the xml of the exported App

    .EXAMPLE
    Export-AzureADApp -ObjectId f230aa0b-9832-431c-a879-a40e57b71d79 -Path C:\temp\

    .EXAMPLE
    Export-AzureADApp -Name TestApp -Path C:\temp\

    .NOTES
    Output from this function will look like this:

    AzureAD App and API Permissions for App Test12345, exported to: C:\temp\Test12345-20200807-0519.xml

    The xml file can be used to import via the local file or can be copied to a GIST

    #>
    [cmdletbinding(DefaultParameterSetName = 'Name')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Name')]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'ObjectId')]
        $ObjectId,

        [Parameter(Mandatory, ParameterSetName = 'Name')]
        [Parameter(Mandatory, ParameterSetName = 'ObjectId')]
        [ValidateScript( { Test-Path $_ } )]
        $Path
    )

    if ($PSCmdlet.ParameterSetName -eq 'Name') {
        $SourceApp = Get-AzureADApplication -filter "DisplayName eq '$Name'"
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'ObjectId') {
        $SourceApp = Get-AzureADApplication -ObjectID $ObjectId
    }

    if (-not $SourceApp) {
        Write-Host "Azure AD Application Name: $Name was not found " -ForegroundColor Red
        continue
    }
    if (@($SourceApp).count -gt 1) {
        $SourceApp | Format-Table -AutoSize
        Write-Host "Duplicate named apps - Provide re-run with -ObjectID." -ForegroundColor Red
        continue
    }

    if ($SecretDate = ($SourceApp | Get-AzureADApplicationPasswordCredential).startdate) { $OldestSecret = ($SecretDate | Sort-Object )[0] }
    else { $OldestSecret = 'No Client Secret' }

    [PSCustomObject]@{
        Name             = $SourceApp.DisplayName
        ObjectId         = $SourceApp.objectid
        AppId            = $SourceApp.AppId
        OldestSecretDate = $OldestSecret
    }
    $App = @{
        DisplayName = $SourceApp.DisplayName
        SourceApp   = $SourceApp
        API         = @{ }
    }
    $AccessList = $SourceApp.RequiredResourceAccess
    foreach ($Access in $AccessList) {
        $ResourceList = $Access.ResourceAccess
        $App['API'][$Access.ResourceAppId] = @{
            ResourceList = [System.Collections.Generic.List[psobject]]
        }
        $RLObj = foreach ($Resource in $ResourceList) {
            [PSCustomObject]@{
                Id   = $Resource.Id
                Type = $Resource.Type
            }
        }
        $App['API'][$Access.ResourceAppId]['ResourceList'] = $RLObj
    }

    $xmlPath = (Join-Path -Path $Path -ChildPath ('{0}-{1}.xml' -f $SourceApp.DisplayName, [DateTime]::Now.ToString('yyyyMMdd-hhmm')) )
    $App | Export-Clixml $xmlPath -Force
    Write-Host "`r`nAzureAD App and API Permissions for App $($SourceApp.DisplayName), exported to: " -ForegroundColor Cyan -NoNewline
    Write-Host "$xmlPath`r`n" -ForegroundColor Yellow
}
