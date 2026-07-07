# Default Editor
$env:EDITOR = "code" # Use VS Code
$env:VISUAL = "code"

# Set up Git default pager
$env:GIT_PAGER = "less -R"

# Add custom scripts directory to PATH if it exists
$CustomScripts = "$HOME\scripts"
if (Test-Path $CustomScripts) {
    $env:PATH += ";$CustomScripts"
}