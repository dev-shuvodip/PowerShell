Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$SiteURL = "https://pphackathonteam5.sharepoint.com/sites/Shuvodip"
$CustomActionTitle = "Send Mail"

Try {
    $Cred = Get-Credential

    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
    $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
 
    $Web = $Ctx.Web
    $UserCustomActions = $Web.UserCustomActions
    $Ctx.Load($UserCustomActions)
    $Ctx.ExecuteQuery()

    $CustomAction = $UserCustomActions | Where-Object { $_.Title -eq $CustomActionTitle } | Select-Object -First 1
    $BasePermissions = New-Object Microsoft.SharePoint.Client.BasePermissions
    $BasePermissions.Set([Microsoft.SharePoint.Client.PermissionKind]::FullMask)
 
    If ($Null -eq $CustomAction) {
        $UserCustomAction = $Ctx.Web.UserCustomActions.Add()
 
        $UserCustomAction.Name = $CustomActionTitle
        $UserCustomAction.Title = $CustomActionTitle
        $UserCustomAction.Location = "Microsoft.SharePoint.StandardMenu"
        $UserCustomAction.Group = "SiteActions"
        $UserCustomAction.Rights = $BasePermissions
        $UserCustomAction.Sequence = 1000
        $UserCustomAction.Url = "https://pphackathonteam5.sharepoint.com/sites/Shuvodip/SitePages/Mail-Send.aspx"   
        $UserCustomAction.Update()
 
        $Ctx.ExecuteQuery()
        Write-Host -f Green "Custom Action Added Successfully!"
    }
    Else {
        write-host -f Yellow "Custom Action Already Exists!"
    }
}
Catch {
    write-host -f Red "Error Adding Custom Action!" $_.Exception.Message
}