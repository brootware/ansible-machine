# Basic Navigation
Set-Alias ll ls
Set-Alias grep Select-String
Set-Alias which Get-Command

# Infrastructure & Automation Shortcuts
Set-Alias tf terraform
Set-Alias ap ansible-playbook

# Git Shortcuts (Using functions to pass arguments easily)
function gs { git status }
function ga { git add . }
function gc { git commit -m $args }
function gp { git push }