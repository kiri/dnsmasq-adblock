#!/bin/bash
wlist=$(mktemp)
trap 'rm $wlist' 1 2 3 15 EXIT

# WHITE LIST
(
	for url in 'https://logroid.github.io/adaway-hosts/hosts_allow.txt' 'https://raw.githubusercontent.com/kiri/hosts_allow/main/adblock-whitelist.txt'
	do
		curl -s $url 
	done | grep -v '^#'| grep -v '^\s*$' | tr -d '\r' | awk '{print $1}'
) | sort | uniq > $wlist

# ADBLOCK LIST
(
	for url in 'https://warui.intaa.net/adhosts/hosts_ipv6.txt' 'https://warui.intaa.net/adhosts/hosts.txt'      
	do
		curl -s $url 
	done | tail -n +2 | awk '{print "address=/"$2"/"$1}'

	for url in 'https://280blocker.net/files/280blocker_domain_'$(date '+%Y%m').txt
	do
		curl -s $url 
	done | tail -n +2 | grep -v '^#' | grep -v '^\s*$' | tr -d '\r' | awk '{print "address=/"$1"/::\naddress=/"$1"/0.0.0.0"}'
) | grep -v -f $wlist | sort | uniq > /etc/dnsmasq.d/adblock.conf

systemctl restart dnsmasq

exit 0

