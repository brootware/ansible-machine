#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
ANSIBLE_REPO="https://github.com/brootware/ansible-machine.git"
REPO_DIR="/tmp/ansible-machine"

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

    if [[ -n "$CI" ]]; then
        echo ">>> [CI] Setting root password non-interactively..."
        echo "$BECOME_PASS" | sudo -S sh -c "echo 'root:$BECOME_PASS' | chpasswd"
    else
        echo ">>> Setting root password (required for 'su' method BECOME password prompt)..."
        echo "Please enter a new password for the root user."
        sudo passwd root
    fi
}

install_galaxy_collections() {
    echo ">>> Installing Ansible Galaxy collections..."
    ansible-galaxy collection install ansible.posix community.general
}

verify_host_in_inventory() {
    echo ">>> Cloning/updating repository to check for hostname..."
    if [ -d "$REPO_DIR" ]; then
        (cd "$REPO_DIR" && git pull)
    else
        git clone "$ANSIBLE_REPO" "$REPO_DIR"
    fi
    
    echo ">>> Verifying hostname exists in inventory..."
    if ! grep -q -E "^\s+($(hostname)|$(hostname -f)):" "$REPO_DIR/hosts.yml"; then
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        echo "ERROR: Host '$(hostname)' not found in hosts.yml." >&2
        echo "Please add this host to '$REPO_DIR/hosts.yml' and commit the change to your repository before proceeding." >&2
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
        exit 1
    fi
    echo ">>> Host '$(hostname)' found in inventory."
}

run_ansible_full() {
    echo ">>> Running full Ansible playbook..."
    verify_host_in_inventory
    install_galaxy_collections

    echo ">>> Running ansible-pull..."
    if [[ -n "$CI" ]]; then
        echo ">>> [CI] Running ansible-pull non-interactively..."
        echo "$BECOME_PASS" | ansible-pull -U "$ANSIBLE_REPO" --purge -K -e "brootware_passwd=${BROOTWARE_PASSWD}"
    else
        # The -U flag handles both cloning for the first time and updating on subsequent runs.
        ansible-pull -U "$ANSIBLE_REPO" --purge -K -e "brootware_passwd=$(read -sp 'Enter password for brootware user: ' p && echo "$p")"
    fi
}

run_ansible_mac() {
    echo ">>> Running Ansible for macOS setup..."
    install_galaxy_collections
    verify_host_in_inventory
    if [[ -n "$CI" ]]; then
        echo ">>> [CI] Running ansible-pull for mac non-interactively..."
        echo "$BECOME_PASS" | ansible-pull -U "$ANSIBLE_REPO" -K --tags "mac" -vv
    else
        # The -K flag will prompt for the sudo password.
        ansible-pull -U "$ANSIBLE_REPO" -K --tags "mac" -vv
    fi
}

run_ansible_dotfiles() {
    install_galaxy_collections
    verify_host_in_inventory
    echo ">>> Running Ansible for dotfiles setup..."

    if [[ -n "$CI" ]]; then
        echo ">>> [CI] Setting root password and using environment variables..."
        echo "$BECOME_PASS" | sudo -S sh -c "echo 'root:$BECOME_PASS' | chpasswd"
    else
        echo ">>> Setting root password (required for 'su' method BECOME password prompt)..."
        echo "Please enter a new password for the root user."
        sudo passwd root
        read -rp "Enter target username: " target_username
        read -rp "Enter target group name (default: ${target_username}): " target_group
        read -rp "Enter target user home directory (default: /home/${target_username}): " target_user_home
    fi

    # Use defaults for group and home if not provided
    target_group=${target_group:-$target_username}
    target_user_home=${target_user_home:-/home/$target_username}

    echo "$BECOME_PASS" | ansible-pull -U "$ANSIBLE_REPO" -K --tags "onlydotfiles" \
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
