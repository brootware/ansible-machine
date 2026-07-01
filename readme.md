# ansible machine 💻

A more complete version of personal dotfiles to automate configuring personal machines.

## How to use

Install Zsh and OhMyZsh for Ubuntu or Debian based distros.

```bash
sudo apt install zsh curl git pipx python3-passlib -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
pipx install --include-deps ansible
pipx ensurepath
```

On ubuntu 26, you also need to install python3 passlib and inject it into pipx

```bash
pipx inject ansible passlib
```

A bit more configuration for latest Ubuntu 26.04 LTS Dekstop. Set root password

```bash
sudo passwd root
```

Define your hostname under [hosts.yml](hosts.yml). Together with the variables

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
