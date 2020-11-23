setup_basebox:
  pkg.installed:
    - pkgs:
      - ntp
      - curl
      - wget
      - rsync
      - zip
      - unzip
      - build-essential
      - nano
      - git

ensure_bashrc_exists:
  file.exists:
    - name: /home/{{ grains['deescalated_user'] }}/.bashrc
