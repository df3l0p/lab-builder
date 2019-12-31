#!/bin/bash
USER={{ansible_user}}

mkdir -p /home/$USER/.ssh
echo "[+] copying ssh keys to /home/$USER/.ssh/"
cp -r /vagrant/res/ansible-ssh-keys/* /home/$USER/.ssh/
chown -R $USER:$USER /home/$USER