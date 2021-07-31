#!/bin/bash
wlist=$(mktemp)
trap 'rm $wlist' 1 2 3 15 EXIT

# ALLOW LIST
(
        for url in 'https://logroid.github.io/adaway-hosts/hosts_allow.txt'
        do
                curl -s $url
        done | grep -v '^#'| grep -v '^\s*$' | tr -d '\r' | awk '{print $1}'
) | sort | uniq > $wlist


# BLOCK LIST
(
        for url in 'https://280blocker.net/files/280blocker_domain_'$(date '+%Y%m').txt
        do
                curl -s $url
        done | tail -n +2 | grep -v '^#' | grep -v '^\s*$' | tr -d '\r' | awk '{print "address=/"$1"/::\naddress=/"$1"/0.0.0.0"}'
) | grep -v -f $wlist | sort | uniq > /etc/dnsmasq.d/adblock.conf

#cat $wlist | \
#       while read line
#               do
#               dig @1.1.1.1 $line +noall +answer | awk -v awk_line="$line" '{if($4 == "A")print "address=/"awk_line"/"$5}'
#               done >>  /etc/dnsmasq.d/adblock.conf

systemctl restart dnsmasq

exit 0
