# ansible machine

```
ansible-pull -U https://github.com/brootware/ansible-machine.git -i "localhost," -K -e my_password=$(read -sp 'Enter password: ' p && echo $p)"
```
