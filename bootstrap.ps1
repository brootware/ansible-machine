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
$ModularConfigBaseUrl = "$BaseUrl/roles/base/files/windows/config"

$DocumentsPath = [Environment]::GetFolderPath('MyDocuments')
$PSConfigPath = Join-Path -Path $DocumentsPath -ChildPath "PowerShell\config"
$PSProfilePath = Join-Path -Path $DocumentsPath -ChildPath "PowerShell\Microsoft.PowerShell_profile.ps1"

# --- Installation ---

Write-Host "Ensuring PowerShell config directory exists at $PSConfigPath..."
if (-not (Test-Path -Path $PSConfigPath)) {
    New-Item -Path $PSConfigPath -ItemType Directory -Force | Out-Null
}

Write-Host "Installing main PowerShell profile..."
Invoke-RestMethod -Uri $ProfileSourceUrl -OutFile $PSProfilePath

Write-Host "Installing modular PowerShell configuration..."
# In a real-world scenario with multiple files, you would list them or fetch a file list.
# For now, we'll assume a known file, e.g., 'aliases.ps1'.
# To make this dynamic, you could host a manifest file in your repo.
# Invoke-RestMethod -Uri "$ModularConfigBaseUrl/aliases.ps1" -OutFile (Join-Path $PSConfigPath "aliases.ps1")

Write-Host "Bootstrap complete! Please restart your PowerShell session."