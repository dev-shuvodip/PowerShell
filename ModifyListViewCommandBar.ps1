$SiteUrl = Read-Host "Enter Site URL"
$Username = Read-Host "Enter username"
$Password = Read-Host "Enter password"

#  Connect to SharePoint Online
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $SecurePassword
Connect-PnPOnline -Url $SiteUrl -Credentials $Credentials

#  Add list and fields
$ListName = "Requests"

$ListViews = Get-PnPView -List $ListName

$ListViews | ForEach-Object ($_) {
  Set-PnPView -Identity $_.Title -List $ListName -Values @{CustomFormatter = @'
{
  "commandBarProps" : {
    "commands": [
      {
        "key": "new",
        "hide": true
      },
      {
        "key": "editInGridView",
        "text": "Quick edit",
        "iconName": "EditTable",
        "primary": false,
        "hide": true
      },
      {
        "key": "share",
        "iconName": "",
        "title": "Share this List",
        "hide": true
      }
    ]
  }
}
'@
  }
}