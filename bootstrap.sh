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

    pipx inject ansible passlib

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
        echo "[ERROR] Host '$(hostname)' not found in local hosts.yml." >&2
        echo "Please add this host to your local hosts.yml file before running." >&2
        # Exit to prevent running with incorrect inventory.
        exit 1
    fi

    install_galaxy_collections

    # Define the absolute path to the local inventory file.
    # This ensures ansible-pull uses your local file, not the one from the repo.
    LOCAL_INVENTORY_FILE="$PWD/hosts.yml"
    echo ">>> Using local inventory file: ${LOCAL_INVENTORY_FILE}"

    # Let ansible-pull create the directory and clone the repo if it doesn't exist.
    # If it exists, it will be updated.
    if [ ! -d "$ANSIBLE_PULL_DIR/.git" ]; then
        echo ">>> Cloning repository for the first time..."
        # We use the local inventory for the initial clone as well.
        ansible-pull -U "$ANSIBLE_REPO" -d "$ANSIBLE_PULL_DIR" --purge -i "$LOCAL_INVENTORY_FILE"
    fi

    # The -K flag will prompt for the 'su' password set in the previous step.
    ansible-pull -U "$ANSIBLE_REPO" -d "$ANSIBLE_PULL_DIR" -i "$LOCAL_INVENTORY_FILE" -K -e "brootware_passwd=$(read -sp 'Enter password for brootware user: ' p && echo "$p")"
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
