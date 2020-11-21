import subprocess

def test():
    return 'custom modules test looks good'

def get_primary_address():
    data = subprocess.check_output(['ip', 'addr'])
    lines = data.split(b'\n')

    ip_address_candidates = []
    for line in lines:
        line = line.lstrip()
        line = line.rstrip()
        if b'inet ' in line:
            print(line)
            ip = line.split(b' ')[1].split(b'/')[0]
            if not ip.startswith(b'inet 127') and not ip.startswith(b'inet 10') and not ip.startswith(b'192.168'):
                ip_address_candidates.append(ip)

    if '172.28.128.1' in ip_address_candidates:
        return '172.28.128.1'

    if '172.28.128.128' in ip_address_candidates:
        return '172.28.128.128'

    if len(ip_address_candidates):
        return ip_address_candidates[0]

#print(get_primary_address())
