#!/bin/bash
USER={{ansible_user}}

mkdir -p /home/$USER/.ssh/
cat /vagrant/res/ansible-ssh-keys/id_rsa.pub >> /home/$USER/.ssh/authorized_keys
chown -R $USER:$USER /home/$USER