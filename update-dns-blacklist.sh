#!/usr/bin/sh
#####################################################
#                                                   #
# File:         update-dns-blacklist.sh             #
# Author:       Allen Zechini                       #
# Description:  scrapes latest DN blacklist and     #
#               restarts the named service          #
#                                                   #
#####################################################

run_scraper() {
	python3 ${SCRAPER} > /dev/null 2>&1

  diff ${WORKING} ${NEW_BLACKLIST}
  if [ $? = 0 ]; then
    echo "${TIMESTAMP}: No blacklist changes...nothing to do" >> ${LOGFILE}
    rm ${NEW_BLACKLIST}
    exit 0
  else
    cp ${WORKING} ${WORKING_BACKUP}
	  cp ${NEW_BLACKLIST} ${WORKING}
  fi
}

# bind vars
BIND_HOME=/etc/bind
WORKING=${BIND_HOME}/named.conf.block
WORKING_BACKUP=${BIND_HOME}/named.conf.block.working_backup
NEW_BLACKLIST=${BIND_HOME}/named.conf.block.new

# Project vars
PROJECT_HOME=/home/azechini/projects/update-dns-blacklist
HTML_DIFF=${PROJECT_HOME}/create-html-diff.py
SCRAPER=${PROJECT_HOME}/scraping-bad-dns.py
NOTIFY=${PROJECT_HOME}/notify.py

# Other vars
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOGFILE=/var/log/update-dns-blacklist.log
USERENV=/home/azechini/.bash_profile

### MAIN ###

run_scraper

sudo systemctl restart bind9
if [ $? != 0 ]; then
  echo "${TIMESTAMP}: New blacklist caused bind9 to fail...reverting blacklist" >> ${LOGFILE}
  cp ${WORKING_BACKUP} ${WORKING}
	systemctl restart bind9
else
  . ${USERENV} > /dev/null 2>&1
  python3 ${NOTIFY}
  NUM=$(diff -y --suppress-common-lines ${WORKING} ${WORKING_BACKUP} | wc -l)
  echo "${TIMESTAMP}: Blacklist updated successfully (${NUM} changes)" >> ${LOGFILE}
fi

rm ${NEW_BLACKLIST}

