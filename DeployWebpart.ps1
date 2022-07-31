$TenantUrl = Read-Host "Enter Tenant Url"
$Username = Read-Host "Enter username"
$Password = Read-Host "Enter password"

#  Connect to SharePoint Online
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword
Connect-PnPOnline -Url $TenantUrl -Credentials $Credentials

$appcatalogURIs = Get-PnPSiteCollectionAppCatalog

$appcatalogURIs | ForEach-Object($_) {
    $appCatConnection = Connect-PnPOnline -Url $_.AbsoluteUrl -Credentials $Credentials

    Add-PnPApp -Path "C:/Users/91891/Documents/Dev/spfx-dynamicCommands/sharepoint/solution/spfx-dynamic-commands.sppkg" -Connection $appCatConnection -Publish -Overwrite

    Update-PnPApp -Identity 5e7d6a8e-06ca-4f93-8a7c-05ed3a45f869 -Scope Site
}