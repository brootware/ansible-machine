# ansible machine

```bash
ansible-pull -U https://github.com/brootware/ansible-machine.git -i "[workstation]\\nlocalhost" -K -e "brootware_passwd=$(read -sp 'Enter password: ' p && echo $p)"
```
