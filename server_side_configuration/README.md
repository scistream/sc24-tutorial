usage

echo "your_vault_password" > .vault_pass

ansible-playbook playbook.yml -i hosts --vault-password-file .vault_pass 
