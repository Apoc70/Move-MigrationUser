<#
  .SYNOPSIS
  Creates a new migration batch and moves migration users one batch to the new batch.

  Thomas Stensitzki

  THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE
  RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

  Version 1.0, 2022-08-23

  Please use GitHub repository for ideas, comments, and suggestions.

  .LINK
  https://github.com/Apoc70/Move-MigrationUser

  .LINK
  http://scripts.granikos.eu

  .DESCRIPTION

  .NOTES
  Requirements
  - Exchange Online Management Shell v2

  Revision History
  --------------------------------------------------------------------------------
  1.0      Initial community release

  .PARAMETER Users

  .EXAMPLE
#>

[CmdletBinding()]
param(
    $Users = @(  'JohnDoe@varunagroup.de' ),
    [string]$BatchName = 'BATCH',
    [switch]$Autostart,
    [switch]$AutoComplete,
    [datetime]$CompleteDateTime,
    $NotificationEmails = 'VarunaAdmin@varunagroup.de',
    [string]$DateTimePattern = 'yyyy-MM-dd'

)

if (($Users | Measure-Object).Count -ne 0) {

    # Create name for en migration batch
    $BatchNamePrefix = ('{0}_{1}' -f $BatchName, ($CompleteDateTime.ToString($DateTimePattern)))
    Write-Verbose -Message (('New target batch name: {0}' -f $BatchName))

    # Fetching users
    Write-Verbose -Message ('Parsing {0} users' -f (($Users | Measure-Object).Count))

    # Fetch migration users and group by BatchId
    # ToDo: Pre-Check users for existence as migration user and a non-completed migration status
    $MigrationsUsers = $Users | ForEach-Object { Get-MigrationUser -Identity $_ | Select-Object Identity, BatchId } | Group-Object BatchId


    $MigrationsUsers | ForEach-Object {

        Write-Output ('{1} - {0}'-f $_.Name, $_.Group.Identity)

        $NewBatchName = ('{0}_{1}' -f $BatchNamePrefix, $_.Name)

        # Create new migration batch
        if($Autostart) {
            $Batch = New-MigrationBatch -Name $NewBatchName -UserIds $_.Group.Identity -DisableOnCopy -AutoStart -NotificationEmails $NotificationEmails
        }
        else {
            $Batch = New-MigrationBatch -Name $NewBatchName -UserIds $_.Group.Identity -DisableOnCopy -NotificationEmails $NotificationEmails
        }

        $Batch | Format-List

        # Set auto completion date and time if not null
        # Set time as Universal Time
        if($null -ne $CompleteDateTime) {

            Write-Verbose ('Setting CompleteAfter to: {0}' -f ($CompleteTime).ToUniversalTime())

            Set-MigrationBatch -Identity $NewBatchName -CompleteAfter ($CompleteTime).ToUniversalTime()
        }

    }
}
else {
    Write-Output 'The list of users is empty. Nothing to do today.'
}
