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

# Use GitHub API to list files in the config directory
$ApiUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/contents/roles/base/files/windows?ref=$Branch"

try {
    $files = Invoke-RestMethod -Uri $ApiUrl -ErrorAction Stop
    
    # Filter for .ps1 files, excluding the main profile which is handled separately
    $ps1Files = $files | Where-Object { 
        $_.type -eq 'file' -and 
        $_.name -like '*.ps1' -and 
        $_.name -ne 'Microsoft.Powershell_profile.ps1' 
    }

    if ($ps1Files) {
        foreach ($file in $ps1Files) {
            $destinationFilePath = Join-Path -Path $PSConfigPath -ChildPath $file.name
            Write-Host "Downloading $($file.name)..."
            Invoke-RestMethod -Uri $file.download_url -OutFile $destinationFilePath
        }
    } else {
        Write-Warning "No modular .ps1 files found in 'roles/base/files/windows'. Only the main profile was installed."
    }
} catch {
    Write-Error "Failed to retrieve file list from GitHub API. Please check the repository path and your internet connection. Error: $($_.Exception.Message)"
}

Write-Host "Bootstrap complete! Please restart your PowerShell session."