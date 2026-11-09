#!/bin/bash

# # Set up the example managed nodes

# multipass launch --name fedora fedora
# multipass launch --name jammy 22.04
# multipass launch --name noble 24.04
# multipass launch --name resolute 26.04
# multipass launch --name trixie debian

# # Generate a ssh key for ansible

ssh-keygen -f ansible -t ed25519 -N '' -C ansible

# Copy the private key to the ubuntu account's ~/.ssh on the control node,

multipass transfer ansible ansible-control-node:/home/ubuntu/.ssh

# and put
#
# private_key_file=~/.ssh/ansible
#
# in the ansible configuration file on the control node.

# Append the public key to the ubuntu account's ~/.ssh/authorized_keys on the managed nodes

cat ansible.pub | multipass exec -n fedora -- bash -c "cat >> /home/ubuntu/.ssh/authorized_keys"
cat ansible.pub | multipass exec -n jammy -- bash -c "cat >> /home/ubuntu/.ssh/authorized_keys"
cat ansible.pub | multipass exec -n noble -- bash -c "cat >> /home/ubuntu/.ssh/authorized_keys"
cat ansible.pub | multipass exec -n resolute -- bash -c "cat >> /home/ubuntu/.ssh/authorized_keys"
cat ansible.pub | multipass exec -n trixie -- bash -c "cat >> /home/ubuntu/.ssh/authorized_keys"
