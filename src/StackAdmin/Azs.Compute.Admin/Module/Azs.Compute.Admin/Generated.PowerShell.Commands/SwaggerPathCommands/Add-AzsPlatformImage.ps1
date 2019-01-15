<#
Copyright (c) Microsoft Corporation. All rights reserved.
Licensed under the MIT License. See License.txt in the project root for license information.

Code generated by Microsoft (R) PSSwagger
Changes may cause incorrect behavior and will be lost if the code is regenerated.
#>

<#
.SYNOPSIS
    Add a virtual machine platform image from a given image configuration.

.DESCRIPTION
    Add a platform image.

.PARAMETER Publisher
    Name of the publisher.

.PARAMETER Offer
    Name of the offer.

.PARAMETER Sku
    Name of the SKU.

.PARAMETER Version
    The version of the virtual machine platform image.

.PARAMETER OsType
    Operating system type.

.PARAMETER OsUri
    Location of the disk.

.PARAMETER BillingPartNumber
    The part number is used to bill for software costs.

.PARAMETER DataDisks
    Data disks used by the platform image.

.PARAMETER Location
    Location of the resource.

.PARAMETER AsJob
    Run asynchronous as a job and return the job object.

.PARAMETER Force
    Don't ask for confirmation.

.EXAMPLE

    PS C:\> Add-AzsPlatformImage -Publisher Test -Offer UbuntuServer -Sku 16.04-LTS -Version 1.0.0 -OsType "Linux" -OsUri "https://test.blob.local.azurestack.external/test/xenial-server-cloudimg-amd64-disk1.vhd"

    Add a new platform image.

#>
using module '..\CustomObjects\PlatformImageObject.psm1'

function Add-AzsPlatformImage {
    [OutputType([PlatformImageObject])]
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Publisher,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Offer,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Sku,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Version,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Unknown', 'Windows', 'Linux')]
        [ValidateNotNullOrEmpty()]
        $OsType,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $OsUri,

        [Parameter(Mandatory = $false)]
        [System.String]
        $BillingPartNumber,

        [Parameter(Mandatory = $false)]
        [Microsoft.AzureStack.Management.Compute.Admin.Models.DataDisk[]]
        $DataDisks,

        [Parameter(Mandatory = $false)]
        [System.String]
        $Location,

        [Parameter(Mandatory = $false)]
        [switch]
        $AsJob,

        [Parameter(Mandatory = $false)]
        [switch]
        $Force
    )

    Begin {
        Initialize-PSSwaggerDependencies -Azure
        $tracerObject = $null
        if (('continue' -eq $DebugPreference) -or ('inquire' -eq $DebugPreference)) {
            $oldDebugPreference = $global:DebugPreference
            $global:DebugPreference = "continue"
            $tracerObject = New-PSSwaggerClientTracing
            Register-PSSwaggerClientTracing -TracerObject $tracerObject
        }
    }

    Process {

        if ($Force.IsPresent -or $PSCmdlet.ShouldProcess("$Publisher/$Offer/$Sku/$Version" , "Add new virtual machine image")) {

            if ( -not $PSBoundParameters.ContainsKey('Location')) {
                $Location = (Get-AzureRMLocation).Location
            }

            if ($null -ne (Get-AzsPlatformImage -Publisher $Publisher -Offer $Offer -Sku $Sku -Version $Version -Location $Location -ErrorAction SilentlyContinue)) {
                Write-Error "A platform image with the same publisher $publisher, offer $offer, sku $sku, and version $version at location $location already exists"
                return
            }

            $NewServiceClient_params = @{
                FullClientTypeName = 'Microsoft.AzureStack.Management.Compute.Admin.ComputeAdminClient'
            }

            $GlobalParameterHashtable = @{}
            $NewServiceClient_params['GlobalParameterHashtable'] = $GlobalParameterHashtable

            $GlobalParameterHashtable['SubscriptionId'] = $null
            if ($PSBoundParameters.ContainsKey('SubscriptionId')) {
                $GlobalParameterHashtable['SubscriptionId'] = $PSBoundParameters['SubscriptionId']
            }

            $ComputeAdminClient = New-ServiceClient @NewServiceClient_params

            # Create object
            $flattenedParameters = @('DataDisks')
            $utilityCmdParams = @{}
            $utilityCmdParams['OsDisk'] = New-OSDiskObject -OsType $OsType -Uri $OsUri
            if ($PSBoundParameters.ContainsKey('BillingPartNumber')) {
                $utilityCmdParams['Details'] = New-ImageDetailsObject -BillingPartNumber $PSBoundParameters['BillingPartNumber']
            }
            $flattenedParameters | ForEach-Object {
                if ($PSBoundParameters.ContainsKey($_)) {
                    $utilityCmdParams[$_] = $PSBoundParameters[$_]
                }
            }
            $NewImage = New-PlatformImageParametersObject @utilityCmdParams

            Write-Verbose -Message 'Performing operation add on $ComputeAdminClient.'
            $TaskResult = $ComputeAdminClient.PlatformImages.CreateWithHttpMessagesAsync($Location, $Publisher, $Offer, $Sku, $Version, $NewImage)

            Write-Verbose -Message "Waiting for the operation to complete."

            $PSSwaggerJobScriptBlock = {
                [CmdletBinding()]
                param(
                    [Parameter(Mandatory = $true)]
                    [System.Threading.Tasks.Task]
                    $TaskResult,

                    [Parameter(Mandatory = $true)]
                    [System.String]
                    $TaskHelperFilePath
                )
                if ($TaskResult) {
                    . $TaskHelperFilePath
                    $GetTaskResult_params = @{
                        TaskResult = $TaskResult
                    }
                    $platformImage = Get-TaskResult @GetTaskResult_params
                    if ($platformImage -and (Get-Member -InputObject $platformImage -Name 'Id') -and $platformImage.Id)
                    {
                        ConvertTo-PlatformImageObject -PlatformImage $platformImage
                    }
                }
            }
        }

        $PSCommonParameters = Get-PSCommonParameter -CallerPSBoundParameters $PSBoundParameters
        $TaskHelperFilePath = Join-Path -Path $ExecutionContext.SessionState.Module.ModuleBase -ChildPath 'Get-TaskResult.ps1'
        if ($AsJob) {
            $ScriptBlockParameters = New-Object -TypeName 'System.Collections.Generic.Dictionary[string,object]'
            $ScriptBlockParameters['TaskResult'] = $TaskResult
            $ScriptBlockParameters['AsJob'] = $true
            $ScriptBlockParameters['TaskHelperFilePath'] = $TaskHelperFilePath
            $PSCommonParameters.GetEnumerator() | ForEach-Object { $ScriptBlockParameters[$_.Name] = $_.Value }

            Start-PSSwaggerJobHelper -ScriptBlock $PSSwaggerJobScriptBlock `
                -CallerPSBoundParameters $ScriptBlockParameters `
                -CallerPSCmdlet $PSCmdlet `
                @PSCommonParameters
        } else {
            Invoke-Command -ScriptBlock $PSSwaggerJobScriptBlock `
                -ArgumentList $TaskResult, $TaskHelperFilePath `
                @PSCommonParameters
        }
    }

    End {
        if ($tracerObject) {
            $global:DebugPreference = $oldDebugPreference
            Unregister-PSSwaggerClientTracing -TracerObject $tracerObject
        }
    }
}

