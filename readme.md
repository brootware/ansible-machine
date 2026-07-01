# ansible machine 💻

A more complete version of personal dotfiles to automate configuring personal machines.

## Pre-requisites

Install Zsh and OhMyZsh for Ubuntu or Debian based distros.

```bash
sudo apt install zsh curl git pipx python3-passlib -y
pipx install --include-deps ansible
pipx ensurepath
```

Define your hostname under [hosts.yml](hosts.yml) locally, together with the variables.

```yml
workstation:
  hosts:
    minty.bruteware.cc: {}
    buntu:
      gnome: true
      ansible_become_method: su
    IdeaPad-Flex-5-14ALC05:
      gnome: true
      ansible_become_method: su
    macbookm2:
      mac: true
```

## 1 script install

This will install the dotfiles from this repo to your machine.

```bash
curl https://raw.githubusercontent.com/brootware/ansible-machine/refs/heads/main/bootstrap.sh > bootstrap.sh && chmod +x bootstrap.sh
./bootstrap.sh
```

## Step by step install

Install oh my zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

On ubuntu 26, you also need to install python3 passlib and inject it into pipx

```bash
pipx inject ansible passlib
```

A bit more configuration for latest Ubuntu 26.04 LTS Dekstop. Set root password

```bash
sudo passwd root
```

Install ansible galaxy collections

```bash
ansible-galaxy collection install ansible.posix community.general
```

and run. For BECOME password: supply the root password you've previously set

```bash
ansible-pull -U https://github.com/brootware/ansible-machine.git -K -e "brootware_passwd=$(read -sp 'Enter password: ' p && echo $p)"
```

For Macbook setup only without creating extra users. Ensure mac is defined in [hosts.yml](hosts.yml).

```bash
ansible-pull -U https://github.com/brootware/ansible-machine.git -K --tags "mac" -vv
```

You can only choose to install dotfiles using

```bash
ansible-pull -U https://github.com/brootware/ansible-machine.git -K --tags "onlydotfiles" -e "target_username=<namehere> target_group=<groupname> target_user_home=<home>"
```
