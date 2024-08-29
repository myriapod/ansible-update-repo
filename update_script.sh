#!/bin/bash

# Script pour mise à jour via Ansible

# Récupération du compte pour le montage

# Sécurisation du mot de passe
ansible-vault encrypt secrets.enc

# Choix de la MAJ à faire
echo ""

ansible-playbook -b playbooks/rhel76-repo.yml --ask-become-password -u ansible -e @secrets.enc --ask-vault-password

ansible-playbook -b playbooks/rhel89-repo.yml --ask-become-password -u ansible -e @secrets.enc --ask-vault-password

ansible-playbook -b playbooks/rhel810-repo.yml --ask-become-password -u ansible -e @secrets.enc --ask-vault-password