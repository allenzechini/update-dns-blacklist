import requests
from pathlib import Path

response = requests.get('https://raw.githubusercontent.com/oznu/dns-zone-blacklist/master/bind/zones.blacklist')

blacklist = '/etc/bind/named.conf.block.new'
with open(blacklist, 'w') as f:
    f.write(response.text.replace('null.zone.file', '/etc/bind/null.zone.file'))
f.close()
