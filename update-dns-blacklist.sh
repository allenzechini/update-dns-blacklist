#!/usr/bin/sh
#####################################################
#                                                   #
# File:         update-dns-blacklist.sh             #
# Author:       Allen Zechini                       #
# Description:  scrapes latest DN blacklist and     #
#               restarts the named service          #
#                                                   #
# 20210413:     initial working version             #
# 20210414:     added diff to check for changes     #
#                                                   #
#####################################################

backup_blacklist() {
	cp ${WORKING} ${WORKING_BACKUP}
}

restore_blacklist() {
	cp ${WORKING_BACKUP} ${WORKING}
}

run_scraper() {
	python3 ${SCRAPER}

  # Check for changes
  diff ${WORKING} ${NEW_BLACKLIST}
  if [ $? = 0 ]; then
    echo "${TIMESTAMP}: No blacklist changes" # testing
    cleanup
    exit 0
  else
	  cp ${NEW_BLACKLIST} ${WORKING}
  fi
}

cleanup() {
	rm ${NEW_BLACKLIST}
}

### MAIN ###

WORKING=/etc/bind/named.conf.block
WORKING_BACKUP=/etc/bind/named.conf.block.working_backup
SCRAPER=/home/allen.zechini/scraping-bad-dns.py # should update to point to a github location/clone
NEW_BLACKLIST=/etc/bind/named.conf.block.new    # hardcoded in scraper
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

backup_blacklist

run_scraper

# Restart bind service
systemctl restart bind9
if [ $? != 0 ]; then
	restore_blacklist
	systemctl restart bind9
fi

cleanup

