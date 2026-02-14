#!/usr/bin/env bash
# Wireshark Packet Analyzer
# Usage:
#	pkt_analyzer logs.pcap - general information

# Menu
while [[ true ]]; do
	echo "Options"
	echo "0: General Information on Host"
	echo "1: DNS Records"
	echo "2: NBNS: NetBios Name Service"
	printf "\n"
	read option
	if [[ $option -eq 0 ]]; then
		host_ips=$(tshark -r $1 -Y "http.request.method == GET" -T fields -e ip.src -e eth.src | tr , '\n' | sort -u | awk '{print $1,$2}' | tr ' ' '\t')
		startofcapture=$(tshark -r $1 -o gui.column.format:"Time,%Yut" | sort -n | head -1)
		endofcapture=$(tshark -r $1 -o gui.column.format:"Time,%Yut" | sort -nr | head -1)
		timeinminutes=$(tshark -r $1 -Tfields -e frame.time_relative | sort -nr | head -1 | awk '{print $1 / 60}' | cut -d '.' -f1)
		timeinseconds=$(tshark -r $1 -Tfields -e frame.time_relative | sort -nr | head -1 | awk '{print $1 % 60}' | cut -d '.' -f1)
		printf "\n"
		printf "#############################\n"
		printf "*********General Information on Host[s]**********\n\n"
		printf "Hosts\t\tMAC address\n"
		printf "${host_ips[@]}\n\n"
		printf "Start of Capture: $startofcapture\n"
		printf "End of capture: $endofcapture\n"
		printf "Total capture time: $timeinminutes min $timeinseconds sec\n"
		printf "#############################\n"
	elif [[ $option -eq 1 ]]; then
		dns_ips=$(tshark -r $1 -Y "dns.flags.response==1" -T fields -e dns.a -e dns.resp.name | tr , '\n' | awk '$1!=""' | awk '$2!="" {print $1, $2}' | tr ' ' '\t')
		printf "\n"
		printf "#############################\n"
		printf "***********DNS A Records*****************\n"
		printf "Ipv4 address\tHostname\n"
		printf "${dns_ips[@]}\n"
	elif [[ $option -eq 2  ]]; then
		nbns_ips=$(tshark -r $1 -Y 'nbns.flags.opcode in {5,8}' -T fields -e nbns.name -e nbns.addr | tr , '\n' | awk '$2!="" {print$1,$3}' | sort -u | tr ' ' '\t')
		printf "\n"
		printf "#############################\n"
		printf "**************NBNS Records***************\n"
		printf "PC name\t\t\tIP address\n"
		printf "${nbns_ips[@]}\n"
	fi
	break
done
