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

function Find-File($name) {
    ls -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
        $place_path = $_.directory
        echo "${place_path}\${_}"
    }
}

function Edit-Hosts { code $env:windir\System32\Drivers\etc\hosts }

function Get-Pubip {(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content}

function Get-Routerip {(Get-NetRoute | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }).NextHop}