Update DNS Blacklist
====================

Description
-----------
This repo contains code that scrapes the web for a maintained list of bad dns (from https://github.com/oznu/dns-zone-blacklist) that contain either malicious code or annoying ads

Scripts
-------
1. scraping-bad-dns.py      : a python script that scrapes a maintained list of zones blacklisted dns containing malware or ads
2. update-dns-blacklist.sh  : a bash script that calls scraping-bad-dns.py, saves the latest changes to the blacklist, and restarts the bind9 service
