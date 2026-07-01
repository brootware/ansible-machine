#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
ANSIBLE_REPO="https://github.com/brootware/ansible-machine.git"
REPO_DIR="/tmp/ansible-machine"
ANSIBLE_PULL_DIR="$HOME/.ansible/pull/$(basename "$ANSIBLE_REPO" .git)"

# --- Helper Functions ---

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Bootstrap script for ansible-machine configuration.

Options:
  -m, --mac         Run the setup for macOS only (tags: mac).
  -d, --dotfiles    Run the setup for dotfiles only (tags: onlydotfiles).
  -h, --help        Display this help message and exit.

If no options are provided, the script performs a full setup for a new
Debian/Ubuntu-based system.
EOF
    exit 0
}

install_deps_debian() {
    echo ">>> Installing dependencies for Debian/Ubuntu..."
    sudo apt-get update
    sudo apt-get install -y zsh curl git pipx python3-passlib

    echo ">>> Installing Oh My Zsh non-interactively..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Oh My Zsh is already installed. Skipping."
    fi

    echo ">>> Installing Ansible with pipx..."
    pipx install --include-deps ansible
    pipx ensurepath

    # The README mentions Ubuntu 26, which might be a typo for 24.04 or a future release.
    # This check makes the script more robust.
    if [ -f /etc/os-release ] && grep -q 'VERSION_ID="24.04"' /etc/os-release; then
        echo ">>> Ubuntu 24.04 detected. Injecting passlib into pipx environment for Ansible."
        pipx inject ansible passlib
    fi

    echo ">>> Setting root password (required for 'su' become method)..."
    echo "Please enter a new password for the root user."
    sudo passwd root
}

install_galaxy_collections() {
    echo ">>> Installing Ansible Galaxy collections..."
    ansible-galaxy collection install ansible.posix community.general
}

run_ansible_full() {
    echo ">>> Running full Ansible playbook..."

    # Ensure the current hostname is in hosts.yml for the playbook to find it.
    # This also implicitly checks that the script is run from the correct directory.
    if [ ! -f "hosts.yml" ] || ! grep -q "$(hostname)" hosts.yml; then
        echo "WARNING: '$(hostname)' not found in hosts.yml. The playbook might not run as expected."
        echo "Please create or update hosts.yml and add this host before running."
        # Exit to prevent running with incorrect inventory.
        # You can comment this out if you want it to proceed anyway.
        exit 1
    fi
    
    echo ">>> Copying local hosts.yml to the Ansible pull directory..."
    mkdir -p "$ANSIBLE_PULL_DIR"
    cp hosts.yml "$ANSIBLE_PULL_DIR/hosts.yml"

    install_galaxy_collections

    # The -K flag will prompt for the 'su' password set in the previous step.
    ansible-pull -U "$ANSIBLE_REPO" -d "$ANSIBLE_PULL_DIR" -i hosts.yml -K -e "brootware_passwd=$(read -sp 'Enter password for brootware user: ' p && echo "$p")"
}

run_ansible_mac() {
    echo ">>> Running Ansible for macOS setup..."
    install_galaxy_collections
    # The -K flag will prompt for the sudo password.
    ansible-pull -U "$ANSIBLE_REPO" -K --tags "mac" -vv
}

run_ansible_dotfiles() {
    install_galaxy_collections
    echo ">>> Running Ansible for dotfiles setup..."
    echo ">>> Setting root password (required for 'su' become method)..."
    echo "Please enter a new password for the root user."
    sudo passwd root
    read -rp "Enter target username: " target_username
    read -rp "Enter target group name (default: ${target_username}): " target_group
    target_group=${target_group:-$target_username}
    read -rp "Enter target user home directory (default: /home/${target_username}): " target_user_home
    target_user_home=${target_user_home:-/home/$target_username}

    # The -K flag will prompt for the sudo password.
    ansible-pull -U "$ANSIBLE_REPO" -K --tags "onlydotfiles" \
        -e "target_username=${target_username}" \
        -e "target_group=${target_group}" \
        -e "target_user_home=${target_user_home}"
}

# --- Main Logic ---

if [ "$#" -gt 0 ]; then
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -m|--mac)
                run_ansible_mac
                shift
                ;;
            -d|--dotfiles)
                run_ansible_dotfiles
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                echo "Error: Invalid option '$1'"
                usage
                ;;
        esac
    done
else
    # Default action: full setup for Debian/Ubuntu
    install_deps_debian
    run_ansible_full
fi

echo "✅ Bootstrap complete!"
