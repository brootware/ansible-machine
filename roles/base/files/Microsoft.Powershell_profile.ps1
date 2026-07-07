# --- Dotfiles Loader ---
$DotfilesConfig = Join-Path (Split-Path -Parent $PROFILE) "config"
if (Test-Path $DotfilesConfig) {
    Get-ChildItem -Path $DotfilesConfig\*.ps1 | ForEach-Object { . $_.FullName }
}
# -----------------------

# Add any machine-specific or temporary overrides below this line if absolutely necessary,
# but ideally, keep all configuration within the modular files.