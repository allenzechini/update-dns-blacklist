#!/usr/bin/sh
#####################################################
#                                                   #
# File:         update-dns-blacklist.sh             #
# Author:       Allen Zechini                       #
# Description:  scrapes latest DN blacklist and     #
#               restarts the named service          #
#                                                   #
#####################################################

backup_blacklist() {
	cp ${WORKING} ${WORKING_BACKUP}
}

restore_blacklist() {
	cp ${WORKING_BACKUP} ${WORKING}
}

run_scraper() {
	python3 ${SCRAPER} > /dev/null 2>&1

  diff ${WORKING} ${NEW_BLACKLIST}
  if [ $? = 0 ]; then
    echo "${TIMESTAMP}: No blacklist changes...nothing to do" >> ${LOGFILE}
    cleanup
    exit 0
  else
    backup_blacklist
	  cp ${NEW_BLACKLIST} ${WORKING}
  fi
}

cleanup() {
	rm ${NEW_BLACKLIST}
}

notify() {
  python3 ${NOTIFY}
}

# bind vars
BIND_HOME=/etc/bind
WORKING=${BIND_HOME}/named.conf.block
WORKING_BACKUP=${BIND_HOME}/named.conf.block.working_backup
NEW_BLACKLIST=${BIND_HOME}/named.conf.block.new    # hardcoded in scraper

# Project vars
PROJECT_HOME=/home/allen.zechini/projects/update-dns-blacklist
SCRAPER=${PROJECT_HOME}/scraping-bad-dns.py
NOTIFY=${PROJECT_HOME}/notify.py

# Other vars
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE=/var/log/update-dns-blacklist.log
USERENV=/home/allen.zechini/.bash_profile

### MAIN ###

run_scraper

systemctl restart bind9
if [ $? != 0 ]; then
  echo "${TIMESTAMP}: New blacklist caused bind9 to fail...reverting blacklist" >> ${LOGFILE}
	restore_blacklist
	systemctl restart bind9
else
  . ${USERENV} > /dev/null 2>&1
  notify
  echo "${TIMESTAMP}: Blacklist updated successfully" >> ${LOGFILE}
fi

cleanup

