$SiteUrl = Read-Host "Enter Site URL"
$Username = Read-Host "Enter username"
$Password = Read-Host "Enter password"

#  Connect to SharePoint Online
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword
Connect-PnPOnline -Url $SiteUrl -Credentials $Credentials

#Get context
$clientContext = Get-PnPContext

#Give component Id of Form Customizer extension
$componentId = "a6b9efd2-2dbe-4f45-807f-e3a527b9fdea"

#Give target content type name over here
$targetContentType = Get-PnPContentType -Identity "Request Item"
#Set target content type read only
$targetContentType.NewFormClientSideComponentId = $componentId
$targetContentType.EditFormClientSideComponentId = $componentId
$targetContentType.DisplayFormClientSideComponentId = $componentId

#Update(UpdateChildren – bool), this value indicates whether the children content type(inheriting from this Content Type) needs to be updated. 0 = False, 1 = True
$targetContentType.Update(0)

$clientContext.ExecuteQuery()
