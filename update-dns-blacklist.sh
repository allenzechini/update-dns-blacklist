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

cleanup() {
	rm ${NEW_BLACKLIST} ${HTMLDIFF}
	# rm ${HTMLDIFF_ZIP}
}

create_diff() {
  python3 ${HTML_DIFF} -f1 ${WORKING} -f2 ${NEW_BLACKLIST}
}

notify() {
  python3 ${NOTIFY}
  # ansible-playbook notify.yml
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
    create_diff
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
HTMLDIFF=/tmp/named.conf.block.htmldiff
# HTMLDIFF_ZIP=/tmp/named.conf.block.htmldiff.zip

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

