# ansible machine

Define your hostname under [hosts.yml](hosts.yml). Together with the variables

```yml
workstation:
  hosts:
    linuxmint:
      cinnamon: true
    buntu:
      gnome: true
```

and run

```bash
ansible-pull -U https://github.com/brootware/ansible-machine.git -K -e "brootware_passwd=$(read -sp 'Enter password: ' p && echo $p)"
```

OR only run the base role on localhost

```bash
ansible-pull -U https://github.com/brootware/ansible-machine.git -i "localhost," -K -e "brootware_passwd=$(read -sp 'Enter password: ' p && echo $p)"
```

