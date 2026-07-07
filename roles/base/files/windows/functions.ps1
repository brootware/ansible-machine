# Quickly reload the profile after making changes
function Reload-Profile {
    . $PROFILE
    Write-Host "Profile reloaded successfully." -ForegroundColor Green
}

# Quickly open dotfiles in your editor
function Edit-Dotfiles {
    code (Split-Path -Parent $PROFILE)
}

# Extract common archives
function Extract-Archive ($Path) {
    Expand-Archive -Path $Path -DestinationPath . -Force
}