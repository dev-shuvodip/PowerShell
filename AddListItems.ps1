$SiteUrl = Read-Host "Enter Site URL"
$Username = Read-Host "Enter username"
$Password = Read-Host "Enter password"

#  Connect to SharePoint Online
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword
Connect-PnPOnline -Url $SiteUrl -Credentials $Credentials
$context = Get-PnPContext

#  Add list and fields
$ListName = "Requests Workflow 3"
New-PnPList -Title $ListName -Template GenericList -OnQuickLaunch
Add-PnPField -List $ListName -DisplayName "Request ID" -InternalName "RequestID" -Type Text -Required -AddToDefaultView
Add-PnPField -List $ListName -DisplayName "Received Date" -InternalName "ReceivedDate" -Type DateTime -AddToDefaultView
Add-PnPField -List $ListName -DisplayName "Status" -InternalName "Status" -Type Choice -Choices "In-transit", "Received", "Processing", "Processed", "Completed" -AddToDefaultView
Add-PnPField -List $ListName -DisplayName "Approved" -InternalName "Approved" -Type Boolean -AddToDefaultView

#  Create arrays for the Choice and Yes/No fields
$Field = Get-PnPField -Identity "Status" -List $ListName
$boolArray = @($true, $false)
$statusChoices = New-Object Microsoft.SharePoint.Client.FieldChoice($context, $Field.Path)
$context.Load($statusChoices)
Invoke-PnPQuery

#  Add Id column to default view
Set-PnPView -Identity "All Items" -List $ListName -Fields @("ID", "Title", "RequestID", "ReceivedDate", "Status", "Approved")

#  Add views to list based on the Status Choices
$statusChoices.Choices | ForEach-Object ($_) {
	Add-PnPView -List $ListName -Title $_ -Fields @("ID", "Title", "RequestID", "ReceivedDate", "Status", "Approved") -Aggregations "<FieldRef Name='ID' Type='COUNT'/>" -Query "<Where><Eq><FieldRef Name='Status' /><Value Type='Choice'>$_</Value></Eq></Where>"
}

#  Add items to the list
for ($i = 1; $i -le 2000; $i++) {
	$choiceValue = $statusChoices.Choices | Get-Random
	$approvedStatus = $boolArray | Get-Random
	$CurrentDate = Get-Date -Format "o"
	$NewTitle = "ReqID$CurrentDate"
	Add-PnPListItem -List $ListName -Values @{
		"Title"        = $NewTitle;
		"RequestID"    = $NewTitle; 
		"ReceivedDate" = [datetime]$CurrentDate; 
		"Approved"     = $approvedStatus; 
		"Status"       = $choiceValue 
	}
}

#  Add indexing to Status column
$targetField = Get-PnPField -List $ListName -Identity "Status" 
$targetField.Indexed = 1 
$targetField.Update()
$context.ExecuteQuery()