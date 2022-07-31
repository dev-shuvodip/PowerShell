$color_palette = @{
"themePrimary" = "#881798";
"themeLighterAlt" = "#060106";
"themeLighter" = "#160418";
"themeLight" = "#29072e";
"themeTertiary" = "#530e5c";
"themeSecondary" = "#791487";
"themeDarkAlt" = "#9526a3";
"themeDark" = "#a43fb1";
"themeDarker" = "#bb68c6";
"neutralLighterAlt" = "#0b0000";
"neutralLighter" = "#150202";
"neutralLight" = "#250505";
"neutralQuaternaryAlt" = "#2f0909";
"neutralQuaternary" = "#370c0c";
"neutralTertiaryAlt" = "#591f1f";
"neutralTertiary" = "#c8c8c8";
"neutralSecondary" = "#d0d0d0";
"neutralPrimaryAlt" = "#dadada";
"neutralPrimary" = "#ffffff";
"neutralDark" = "#f4f4f4";
"black" = "#f8f8f8";
"white" = "#000000";
}

Connect-PnPOnline -Url "https://developmentcentral.sharepoint.com/sites/DevelopmentCentral" -Interactive

Add-PnPTenantTheme -Identity "Dark Theme Purple" -Palette $color_palette -IsInverted $false