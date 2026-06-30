# ansible machine

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
    linuxmint:
      cinnamon: true
    buntu:
      gnome: true
    ubuntu26laptop:
      gnome: true
      ansible_become_method: su
```

and run

```bash
ansible-pull -U https://github.com/brootware/ansible-machine.git -K -e "brootware_passwd=$(read -sp 'Enter password: ' p && echo $p)"
```

OR only run the base role on localhost

```bash
ansible-pull -U https://github.com/brootware/ansible-machine.git -i "localhost," -K -e "brootware_passwd=$(read -sp 'Enter password: ' p && echo $p)"
```

