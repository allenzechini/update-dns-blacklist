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
# 20210415:     added simple logging                #
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
    echo "${TIMESTAMP}: No blacklist changes...nothing to do" >> ${LOGFILE}
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

HOME=/home/allen.zechini/projects/update-dns-blacklist
WORKING=/etc/bind/named.conf.block
WORKING_BACKUP=/etc/bind/named.conf.block.working_backup
SCRAPER=${HOME}/scraping-bad-dns.py
NEW_BLACKLIST=/etc/bind/named.conf.block.new    # hardcoded in scraper
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE=/var/log/update-dns-blacklist.log

backup_blacklist

run_scraper

# Restart bind service
systemctl restart bind9
if [ $? != 0 ]; then
  echo "${TIMESTAMP}: New blacklist caused bind9 to fail...reverting blacklist" >> ${LOGFILE}
	restore_blacklist
	systemctl restart bind9
fi

echo "${TIMESTAMP}: Blacklist updated successfully" >> ${LOGFILE}
cleanup

