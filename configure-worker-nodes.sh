#!/bin/bash -e

get_join_command ()
{
sudo /vagrant/join_command.sh
}
add_master_node_key ()
{
cat /vagrant/master_node.pub >> /home/vagrant/.ssh/authorized_keys
}

get_join_command
add_master_node_key
