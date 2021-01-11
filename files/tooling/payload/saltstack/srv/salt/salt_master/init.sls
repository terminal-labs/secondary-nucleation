install_salt_deps:
  pkg.installed:
    - pkgs:
      - python-software-properties
      - python-dev
      - python-m2crypto
      - python-virtualenv
      - zlib1g-dev
      - libffi-dev
      - python3-dev

# bitbucket.org:
#   ssh_known_hosts:
#     - present
#     - fingerprint: {{ grains['fingerprint'] }}
#     - fingerprint_hash_type: md5
#     - timeout: 90

clone_salt:
   git.latest:
     - branch: v3000.3
     - name: https://bitbucket.org/terminal_labs/saltstack.git
     - target: /home/saltmaster/salt_src
     - user: root

/home/saltmaster/salt_src:
  file.directory:
    - user: saltmaster
    - group: saltmaster
    - recurse:
      - user
      - group

create_salt_controlplane:
  file.directory:
    - name: /home/saltmaster/salt_controlplane
    - user: saltmaster
    - group: saltmaster

install_venv:
  cmd.run:
    - name: virtualenv -p /usr/bin/python3 /home/saltmaster/salt_venv
    - runas: saltmaster

update_pip:
  cmd.run:
    - name: ./bin/pip install -U setuptools; ./bin/pip install -U pip
    - cwd: /home/saltmaster/salt_venv
    - runas: saltmaster

place_pip_requirements_file:
  file.managed:
    - name: /home/saltmaster/salt_venv/requirements.txt
    - source: salt://salt_master/files/requirements.txt
    - user: saltmaster
    - group: saltmaster

place_pip_requirements:
  cmd.run:
    - name: ./bin/pip install -r requirements.txt
    - cwd: /home/saltmaster/salt_venv
    - runas: saltmaster

install_salt_src:
  cmd.run:
    - name: ./bin/pip install -e /home/saltmaster/salt_src
    - cwd: /home/saltmaster/salt_venv
    - runas: saltmaster

create_salt_root_dir:
  file.directory:
    - name: /home/saltmaster/salt_controlplane/etc/salt
    - user: saltmaster
    - group: saltmaster
    - makedirs: True

create_modules_dir:
  file.directory:
    - name: /home/saltmaster/salt_controlplane/etc/salt/_modules
    - user: saltmaster
    - group: saltmaster
    - makedirs: True

/home/saltmaster/salt_controlplane/etc/pillar:
  file.directory:
    - user: saltmaster
    - group: saltmaster
    - recurse:
      - user
      - group

place_cluster_files:
  cmd.run:
    - name: cp -r /vagrant/inflation_resources/cluster_init /home/saltmaster/salt_controlplane/etc/salt
    - cwd: /home/saltmaster
    - runas: saltmaster

place_deploy_script_files:
  cmd.run:
    - name: cp -r /vagrant/inflation_resources/cloud.deploy.d /home/saltmaster/salt_controlplane/etc/salt
    - cwd: /home/saltmaster
    - runas: saltmaster

place_inflation_module_file:
  file.managed:
    - name: /home/saltmaster/salt_controlplane/etc/salt/_modules/inflation.py
    - source: salt://salt_master/files/inflation.py
    - user: saltmaster
    - group: saltmaster

place_pillar_top_file:
  file.managed:
    - name: /home/saltmaster/salt_controlplane/etc/pillar/top
    - source: salt://salt_master/files/top.txt
    - user: saltmaster
    - group: saltmaster

place_pillar_saltmine_file:
  file.managed:
    - name: /home/saltmaster/salt_controlplane/etc/pillar/saltmine
    - source: salt://salt_master/files/saltmine.txt
    - user: saltmaster
    - group: saltmaster

place_salt_cloud_file:
  file.managed:
    - name: /home/saltmaster/salt_controlplane/etc/salt/cloud
    - source: salt://salt_master/files/etc/cloud
    - user: saltmaster
    - group: saltmaster

place_salt_master_file:
  file.managed:
    - name: /home/saltmaster/salt_controlplane/etc/salt/master
    - source: salt://salt_master/files/etc/master
    - user: saltmaster
    - group: saltmaster

place_salt_minion_file:
  file.managed:
    - name: /home/saltmaster/salt_controlplane/etc/salt/minion
    - source: salt://salt_master/files/etc/minion
    - user: saltmaster
    - group: saltmaster

place_salt_cloud_providers_file:
  cmd.run:
    - name: cp -r /vagrant/.tmp/cloud.providers /home/saltmaster/salt_controlplane/etc/salt/cloud.providers
    - cwd: /home/saltmaster
    - runas: saltmaster

place_salt_cloud_profiles_file:
  cmd.run:
    - name: cp -r /vagrant/.tmp/cloud.profiles /home/saltmaster/salt_controlplane/etc/salt/cloud.profiles
    - cwd: /home/saltmaster
    - runas: saltmaster

place_salt_cloud_map_file:
  cmd.run:
    - name: cp -r /vagrant/.tmp/cloud.map /home/saltmaster/salt_controlplane/etc/salt/cloud.map
    - cwd: /home/saltmaster
    - runas: saltmaster

place_imported_salt_states:
  cmd.run:
    - name: cp -r /vagrant/.tmp/imported_salt_states/. /home/saltmaster/salt_controlplane/etc/salt
    - cwd: /home/saltmaster
    - runas: saltmaster

place_cloud_driver_keys:
  cmd.run:
    - name: cp -r /vagrant/auth/keys/. /home/saltmaster/salt_controlplane/keys
    - cwd: /home/saltmaster

place_salt_cloud_patch_dir:
  cmd.run:
    - name: cp -r /vagrant/inflation_resources/vboxsaltdriver /home/saltmaster/vboxsaltdriver_src
    - cwd: /home/saltmaster
    - runas: saltmaster

install_salt_cloud_driver:
  cmd.run:
    - name: ./bin/pip install -e ../vboxsaltdriver_src
    - cwd: /home/saltmaster/salt_venv
    - runas: saltmaster

patch_saltcloud:
  cmd.run:
    - name: bash /home/saltmaster/vboxsaltdriver_src/patch.sh
    - cwd: /home/saltmaster
    - runas: saltmaster

create_keys_dir:
  file.directory:
    - name: /home/saltmaster/salt_controlplane/keys
    - user: saltmaster

generate_ssh_key_for_universal_login:
  cmd.run:
    - name: ssh-keygen -q -N '' -f /var/tmp/universal_cluster_key
    - runas: saltmaster
    - unless: test -f /var/tmp/universal_cluster_key

place_pri_ssh_key_for_universal_login:
  cmd.run:
    - name: cp /var/tmp/universal_cluster_key /home/saltmaster/salt_controlplane/etc/salt/universal_cluster_key
    - cwd: /home/saltmaster

place_pub_ssh_key_for_universal_login:
  cmd.run:
    - name: cp /var/tmp/universal_cluster_key.pub /home/saltmaster/salt_controlplane/etc/salt/universal_cluster_key.pub
    - cwd: /home/saltmaster
    - runas: saltmaster

# run_my_script.sh:
#   cmd.script:
#     - name: /home/saltmaster/salt_controlplane/rename.sh
#     - source: salt://salt_master/files/srv/salt/bash_scripts/rename.sh

# install_internal_cli_deps:
#   cmd.run:
#     - name: ./bin/pip install click bash
#     - cwd: /home/saltmaster/salt_venv
#     - runas: saltmaster

/home/saltmaster:
  file.directory:
    - user: saltmaster
    - group: saltmaster
    - recurse:
      - user
      - group

/home/vagrant:
  file.directory:
    - user: vagrant
    - group: vagrant
    - recurse:
      - user
      - group
