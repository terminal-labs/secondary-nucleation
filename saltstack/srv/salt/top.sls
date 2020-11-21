base:
  'roles:master':
    - match: grain
    - clean
    - basebox
    - basebox.symlink
    - basebox.modify_bash_env
    - users
    - salt_master
