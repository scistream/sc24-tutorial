## Pre requisites

Make sure you have Ansible installed on this machine.

Make sure you have ssh credentials to the target machines

Make sure you have the proper host file:

```
cat hosts
[scistream_servers]
ec2-scistream-1 ansible_host=3.237.85.101
ec2-scistream-2 ansible_host=44.200.11.77
ec2-scistream-3 ansible_host=3.238.193.24

[scistream_servers:vars]
ansible_ssh_private_key_file=~/.ssh/sc24.pem
ansible_user=ubuntu
```

Here is a quick validation test

```
ansible -m ping -i hosts all
ec2-scistream-2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.12"
    },
    "changed": false,
    "ping": "pong"
}
```
## usage

echo "your_vault_password" > .vault_pass

ansible-playbook playbook.yml -i hosts --vault-password-file .vault_pass 
