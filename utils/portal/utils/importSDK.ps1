param (
    [string]$CustomerPortalSDKLatestTag,
    [string]$CustomerPortalSDKBaseReleaseUrl,
    [string]$CustomerPortalSDKRepositoryUser,
    [string]$CustomerPortalSDKRepositoryPassword
)

# Get Latest CustomerPortal SDK Release Tag
if ([string]::IsNullOrEmpty($CustomerPortalSDKLatestTag)) {
    $CustomerPortalSDKLatestReleaseAPI = "https://api.github.com/repos/criticalmanufacturing/portal-sdk/releases/latest"
    $CustomerPortalSDKLatestTag = Invoke-WebRequest -Uri $CustomerPortalSDKLatestReleaseAPI | % { $_.Content } | ConvertFrom-Json | % { $_.tag_name }
}

# Download the latest release powershell asset
$CustomerPortalSDKPowershellAssetName = "Cmf.CustomerPortal.Sdk.Powershell-$CustomerPortalSDKLatestTag.zip"

if ([string]::IsNullOrEmpty($CustomerPortalSDKBaseReleaseUrl)) {
    $CustomerPortalSDKBaseReleaseUrl = "https://github.com/criticalmanufacturing/portal-sdk/releases/latest/download/"
}
$CustomerPortalSDKReleaseUrl = "$CustomerPortalSDKBaseReleaseUrl/$CustomerPortalSDKPowershellAssetName"

New-Item -ItemType directory -Path .\sdk -Force | Out-Null
$requestHeaders = @{ Authorization = "Basic "+ [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("${CustomerPortalSDKRepositoryUser}:${CustomerPortalSDKRepositoryPassword}")) }
Invoke-WebRequest -Uri $CustomerPortalSDKReleaseUrl -OutFile "./sdk/$CustomerPortalSDKPowershellAssetName" -Headers $requestHeaders

Expand-Archive .\sdk\$CustomerPortalSDKPowershellAssetName -DestinationPath "./sdk2/" -Force
Remove-Item .\sdk\$CustomerPortalSDKPowershellAssetName
Import-Module .\sdk\Cmf.CustomerPortal.Sdk.Powershell.dll
