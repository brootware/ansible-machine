<#
.SYNOPSIS
    Bootstraps the PowerShell dotfiles from the brootware/ansible-machine repository.
.DESCRIPTION
    This script downloads and installs the PowerShell profile and configuration files
    to the user's PowerShell documents directory. It ensures the necessary directory
    structure exists and then copies the files from the repository.
.EXAMPLE
    iex (irm 'https://raw.githubusercontent.com/brootware/ansible-machine/main/bootstrap.ps1')
    This command downloads and executes the script from GitHub.
#>

# --- Configuration ---
$RepoOwner = "brootware"
$RepoName = "ansible-machine"
$Branch = "main"
$BaseUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch"

$ProfileSourceUrl = "$BaseUrl/roles/base/files/windows/Microsoft.Powershell_profile.ps1"
$ModularConfigBaseUrl = "$BaseUrl/roles/base/files/windows"

$DocumentsPath = [Environment]::GetFolderPath('MyDocuments')
$PSConfigPath = Join-Path -Path $DocumentsPath -ChildPath "WindowsPowerShell\config"
$PSProfilePath = Join-Path -Path $DocumentsPath -ChildPath "WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# --- Installation ---

Write-Host "Ensuring PowerShell config directory exists at $PSConfigPath..."
if (-not (Test-Path -Path $PSConfigPath)) {
    New-Item -Path $PSConfigPath -ItemType Directory -Force | Out-Null
}

Write-Host "Installing main PowerShell profile..."
Invoke-RestMethod -Uri $ProfileSourceUrl -OutFile $PSProfilePath

Write-Host "Installing modular PowerShell configuration..."

# Define the list of modular config files to download.
# This avoids hitting the GitHub API and its rate limits.
$ModularConfigFiles = @(
    "aliases.ps1",
    "functions.ps1"
    "env.ps1"
    "prompt.ps1"
)

foreach ($fileName in $ModularConfigFiles) {
    $sourceUrl = "$ModularConfigBaseUrl/$fileName"
    $destinationPath = Join-Path -Path $PSConfigPath -ChildPath $fileName
    Write-Host "Downloading $fileName..."
    Invoke-RestMethod -Uri $sourceUrl -OutFile $destinationPath
}

Write-Host "Bootstrap complete! Please restart your PowerShell session."