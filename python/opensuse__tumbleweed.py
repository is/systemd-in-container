#!/usr/bin/env python
from common import *

C.update({
  'MIRROR': 'tsinghua',
})

command_line()

MIRROR = C.get('MIRROR')
FROM = 'opensuse/tumbleweed:latest'
TSINGHUA_MIRROR_URL = 'http://mirrors.aliyun.com/opensuse/tumbleweed'

CNAME = 'o'

sh(f'''buildah from --name {CNAME} --pull-never {FROM}''')

r = buildah_run(CNAME)

if MIRROR == 'tsinghua':
  MURL = 'http://mirrors.aliyun.com/opensuse/tumbleweed'
  r(f'zypper mr -da')
  r(f'zypper ar -f {MURL}/repo/oss oss')
  r(f'zypper ar -f {MURL}/repo/non-oss non-oss')
  r(f'zypper ref')

r(f'zypper up')

r(f'zypper -n in systemd openssh-server iproute2')

ROOTPW = C['ROOTPW']
SSH_KEY = C['SSH_KEY']
AUTH_FILE = '/root/.ssh/authorized_keys'

r(f'usermod --password $(echo {ROOTPW}|openssl passwd -1 stdin) root')
r(f'mkdir -p /root/.ssh')
r(f'chmod 700 /root/.ssh')
r(f'''sh -c "echo '{SSH_KEY}' > {AUTH_FILE}"''')
r(f'chmod 600 {AUTH_FILE}')


sh(f'''buildah config --cmd='["/usr/lib/systemd/systemd"]' o''')
#sh(f'''buildah rm {CNAME}''')


# vim: ts=2 sts=2 ai expandtab
