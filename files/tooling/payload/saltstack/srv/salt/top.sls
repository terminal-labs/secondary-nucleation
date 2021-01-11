base:
  'roles:master':
    - match: grain
    - clean
    - basebox
    - users
    - salt_master
