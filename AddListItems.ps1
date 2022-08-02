$SiteUrl = Read-Host "Enter Site URL"
$Username = Read-Host "Enter username"
$Password = Read-Host "Enter password"

#  Connect to SharePoint Online
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword
Connect-PnPOnline -Url $SiteUrl -Credentials $Credentials
$context = Get-PnPContext

#  Add list and fields
$ListName = "Requests"
New-PnPList -Title $ListName -Template GenericList -OnQuickLaunch

# Enable content types in list
Set-PnPList -Identity $ListName -EnableContentTypes $true

# Add an existing content type to a list and set it as the default content type
$ContentType = "Request Item"
Add-PnPContentTypeToList -List $ListName -ContentType $ContentType -DefaultContentType

<# Add fields to a list

Add-PnPField -List $ListName -DisplayName "Request ID" -InternalName "RequestID" -Type Text -Required -AddToDefaultView
Add-PnPField -List $ListName -DisplayName "Received Date" -InternalName "ReceivedDate" -Type DateTime -AddToDefaultView
Add-PnPField -List $ListName -DisplayName "Status" -InternalName "Status" -Type Choice -Choices "In-transit", "Received", "Processing", "Processed", "Completed" -AddToDefaultView
Add-PnPField -List $ListName -DisplayName "Approved" -InternalName "Approved" -Type Boolean -AddToDefaultView 

#>

#  Create arrays for the Choice and Yes/No fields
$Field = Get-PnPField -Identity "Status" -List $ListName
$boolArray = @($true, $false)
$statusChoices = New-Object Microsoft.SharePoint.Client.FieldChoice($context, $Field.Path)
$context.Load($statusChoices)
Invoke-PnPQuery

# Add custom formatting to Status field
Set-PnPField -Identity $Field.Title -List $ListName -Values @{CustomFormatter = @'
{
  "$schema": "https://developer.microsoft.com/json-schemas/sp/v2/column-formatting.schema.json",
  "elmType": "div",
  "style": {
    "flex-wrap": "wrap",
    "display": "flex"
  },
  "children": [
    {
      "elmType": "div",
      "style": {
        "box-sizing": "border-box",
        "padding": "4px 8px 5px 8px",
        "overflow": "hidden",
        "text-overflow": "ellipsis",
        "display": "flex",
        "border-radius": "16px",
        "height": "24px",
        "align-items": "center",
        "white-space": "nowrap",
        "margin": "4px 4px 4px 4px"
      },
      "attributes": {
        "class": {
          "operator": ":",
          "operands": [
            {
              "operator": "==",
              "operands": [
                "[$Status]",
                "In-transit"
              ]
            },
            "sp-css-backgroundColor-BgDarkPurple sp-css-borderColor-WhiteFont sp-css-color-WhiteFont",
            {
              "operator": ":",
              "operands": [
                {
                  "operator": "==",
                  "operands": [
                    "[$Status]",
                    "Received"
                  ]
                },
                "sp-css-backgroundColor-BgBlue sp-css-borderColor-WhiteFont sp-css-color-WhiteFont",
                {
                  "operator": ":",
                  "operands": [
                    {
                      "operator": "==",
                      "operands": [
                        "[$Status]",
                        "Processing"
                      ]
                    },
                    "sp-css-backgroundColor-BgBrown sp-css-borderColor-WhiteFont sp-css-color-WhiteFont",
                    {
                      "operator": ":",
                      "operands": [
                        {
                          "operator": "==",
                          "operands": [
                            "[$Status]",
                            "Processed"
                          ]
                        },
                        "sp-css-backgroundColor-BgGreen sp-css-borderColor-WhiteFont sp-css-color-WhiteFont",
                        {
                          "operator": ":",
                          "operands": [
                            {
                              "operator": "==",
                              "operands": [
                                "[$Status]",
                                "Completed"
                              ]
                            },
                            "sp-css-backgroundColor-BgLightPurple sp-css-borderColor-LightPurpleFont sp-css-color-LightPurpleFont",
                            {
                              "operator": ":",
                              "operands": [
                                {
                                  "operator": "==",
                                  "operands": [
                                    "[$Status]",
                                    ""
                                  ]
                                },
                                "",
                                "sp-field-borderAllRegular sp-field-borderAllSolid sp-css-borderColor-neutralSecondary"
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      },
      "txtContent": "[$Status]"
    }
  ]
}
'@
}

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