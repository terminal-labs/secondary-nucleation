#!/usr/bin/env bash

function saltmaster {
    start="su saltmaster -c \"source bin/activate; python /home/saltmaster/salt_src/scripts/salt '"
    middle="' -c /home/saltmaster/salt_controlplane/etc/salt "
    end=" --timeout 1\""
    command=$start$1$middle$2$end
    eval $command
}

cd /home/saltmaster/salt_venv
echo "stoping bootstrap salt minion and salt master"
ps aux | grep -ie salt-master | grep -v grep | awk '{print $2}' | xargs kill -9
ps aux | grep -ie salt-minion | grep -v grep | awk '{print $2}' | xargs kill -9

echo "starting salt master service"
su saltmaster -c "source bin/activate; python /home/saltmaster/salt_src/scripts/salt-master -c /home/saltmaster/salt_controlplane/etc/salt -d"
echo "starting salt minion service"
su saltmaster -c "source bin/activate; python /home/saltmaster/salt_src/scripts/salt-minion -c /home/saltmaster/salt_controlplane/etc/salt -d"

echo "waiting for salt-minion (on master node) to fully boostrap"
while ! test -f "/home/saltmaster/salt_master_root/etc/salt/pki/master/minions/master"
do
  echo "Still waiting for minion to boostrap"
  su saltmaster -c "source bin/activate; python /home/saltmaster/salt_src/scripts/salt-key -A -y -c /home/saltmaster/salt_controlplane/etc/salt"
  sleep 1
done

sleep 10

echo "waiting for minion (on master node) to connect"
while ! su saltmaster -c "source bin/activate; python /home/saltmaster/salt_src/scripts/salt 'master' -c /home/saltmaster/salt_controlplane/etc/salt test.ping --timeout 1 --no-color" | grep 'True'
do
  sleep 1
  echo "Still waiting for minion to connect"
done

echo "pinging master"
saltmaster "master" "test.ping"

echo "set reboot round grain on master"
saltmaster "master" "grains.setval reboot_round 0"

echo "syncing custom modules on master"
saltmaster "master" "saltutil.sync_modules"

echo "set default grains on master"
saltmaster "master" "grains.setval primary_role master"
saltmaster "master" "grains.setval vm_size 8gb"

raw_public_key=$(cat /var/tmp/universal_cluster_key.pub)
FS=' ' read -r -a array <<< "$raw_public_key"
public_key="${array[1]}"

echo "setting salt master ip address"
host_ip_address=$(su saltmaster -c "source bin/activate; python /home/saltmaster/salt_src/scripts/salt 'master' -c /home/saltmaster/salt_controlplane/etc/salt inflation.get_primary_address --output newline_values_only --timeout 1 --no-color")
echo $host_ip_address


sed -i -e 's~{{ master_address }}~'"$host_ip_address"'~g' /home/saltmaster/salt_controlplane/etc/salt/cloud.providers

vendor=$(cat /vagrant/.tmp/vendor)
echo $vendor

if [ "$vendor" == "digitalocean" ]
then
  personal_access_token=$(cat /vagrant/.tmp/auth_token)
  sed -i -e 's~{{ personal_access_token }}~'"$personal_access_token"'~g' /home/saltmaster/salt_controlplane/etc/salt/cloud.providers
fi

if [ "$vendor" == "aws" ]
then
  personal_access_key=$(cat /vagrant/.tmp/secret_auth_token)
  sed -i -e 's~{{ personal_access_key }}~'"$personal_access_key"'~g' /home/saltmaster/salt_controlplane/etc/salt/cloud.providers
  personal_access_token=$(cat /vagrant/.tmp/auth_token)
  sed -i -e 's~{{ personal_access_token }}~'"$personal_access_token"'~g' /home/saltmaster/salt_controlplane/etc/salt/cloud.providers
  echo $personal_access_key
  echo $personal_access_token
fi

bash /vagrant/inflation_resources/scripts/spawn_minions.sh

# echo "pinging minions"
# saltmaster "*" "test.ping"
#
# echo "getting minions ip addresses"
# saltmaster "*" "network.ip_addrs"
#
# echo "set reboot round grain - first run"
# saltmaster "*" "grains.setval reboot_round 0"
#
# echo "syncing all salt resources nodes"
# saltmaster "*" "saltutil.sync_all"
#
# echo "updateing mine functions on all nodes"
# saltmaster "*" "mine.update"
#
# echo "configuring basic cluster nodes"
# saltmaster "*" "state.sls cluster_init"
#
# echo "set hostname grain"
# saltmaster "*" "state.sls cluster_init.set_hostname_grain"
#
# echo "set cluster nodes grain"
# saltmaster "*" "state.sls cluster_init.set_cluster_nodes_grain"
#
# echo "set cluster fqdn"
# saltmaster "*" "state.sls cluster_init.set_cluster_fqdn"
#
# echo "setting up ssh key pairs for salt"
# saltmaster "*" "ssh.set_auth_key vagrant $public_key enc='rsa'"
#
# echo "setting up ssh key pairs for universal login"
# saltmaster "*" "state.sls cluster_init.distribute_ssh_keys_for_universal_login"
#
# echo "setting up setup passwordless sudo"
# saltmaster "*" "state.sls cluster_init.setup_passwordless_sudo"
#
# echo "accept host keys"
# saltmaster "master" "state.sls cluster_init.accept_hostkeys"
#
# echo "copy known_hosts file for salt distribution"
# saltmaster "master" "state.sls cluster_init.prepare_known_hosts_for_distribution"
#
# echo "distribute known_hosts file"
# saltmaster "*" "state.sls cluster_init.distribute_known_hosts_file"
#
# echo "run highstate - first run"
# saltmaster "*" "state.highstate"
#
# sleep 60s # Waits 60 seconds for minions to reboot. We need more reliable way to deterministically delay this scirpt untill all minoins are back up.
#
# echo "pinging minions after first reboot round"
# saltmaster "*" "test.ping"
#
# echo "set reboot round grain - second run"
# saltmaster "*" "grains.setval reboot_round 1"
#
# echo "run highstate - second run"
# saltmaster "*" "state.highstate"
#
# sleep 60s # Waits 60 seconds for services to load. We need more reliable way to deterministically delay this scirpt untill all minoins are back up.
#
# echo "run keystone state"
# saltmaster "*" "state.sls keystone"
