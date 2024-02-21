#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW_BOLD='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

printf "\n"
printf "${YELLOW_BOLD}"
printf '
   ______      __  __                 ____      ____
  / ____/___ _/ /_/ /_  ___  _____   /  _/___  / __/___
 / / __/ __ `/ __/ __ \/ _ \/ ___/   / // __ \/ /_/ __ \
/ /_/ / /_/ / /_/ / / /  __/ /     _/ // / / / __/ /_/ /
\____/\__,_/\__/_/ /_/\___/_/     /___/_/ /_/_/  \____/

'

printf '\n\n'

option=" "
specificOption=""

while true;do
	printf "${BLUE}[ 1 ]${NC} -${BOLD} Zone Transfer${NC}\n${BLUE}[ 2 ]${NC} - ${BOLD}DNS Search${NC}\n${BLUE}[ 3 ]${NC} - ${BOLD}Reverse DNS${NC}\n${BLUE}[ 4 ]${NC} - ${BOLD}Subdomain TakeOver${NC}\n\n"
	read -p "Digite uma opção: " option

	if [ "$option" = '3' ]; then
		read -p "Digite o IP: " specificOption
		if [ -z "$specificOption" ]; then
			printf "\n${RED}ERRO!${NC} Digite um valor.\n\n"
		else
			break
		fi
	elif [ "$option" = '1' ] || [ "$option" = '2' ] || [ "$option" = '4' ];then
		read -p "Digite o domínio: " specificOption
		if [ -z "$specificOption" ]; then
			printf "\n${RED}ERRO!${NC} Digite um valor.\n\n"
		else
			break
		fi
	else
		printf "\n${RED}ERRO!${NC} Digite um valor entre 1 e 4.\n\n"
	fi
done

printf '\n\n\n'

case $option in
	'1')
		printf "${GREEN}${BOLD}ZONE TRANSFER:${NC}\n"
		printf "${GREEN}${BOLD}----------------------------${NC}\n\n"
		for server in $(host -t ns $specificOption | cut -d " " -f 4);
		do
			host -l $specificOption $server 2>/dev/null | grep -E -e -v "Host $specificOption not found|Transfer failed"
		done
	;;

	'2')
		printf "${GREEN}${BOLD}DNS SEARCH:${NC}\n"
                printf "${GREEN}${BOLD}----------------------------${NC}\n\n"

		for subdomain in $(cat /usr/share/dnsrecon/subdomains-top1mil.txt);
		do
			host $subdomain.$specificOption 2>/dev/null | grep -Ev "NXDOMAIN|timed out|no servers could be reached|SERVFAIL|empty|host:"
		done
	;;

	'3')
		printf "${GREEN}${BOLD}REVERSE DNS:${NC}\n"
                printf "${GREEN}${BOLD}----------------------------${NC}\n\n"

		domain=$(echo $specificOption | cut -d "." -f1-3)
		removeIp=$(echo $specificOption | cut -d "." -f1-3 | sed "s/\./-/g")

		for ip in $(seq $(whois $specificOption | grep "inetnum" | cut -d " " -f 9,11 | sed 's/ /./g' | cut -d "." -f 4,8 | sed 's/\./ /g'));
		do
			host -t ptr $domain.$ip | grep -v "$removeIp" | cut -d " " -f 5
		done
	;;

	'4')
		printf "${GREEN}${BOLD}SUBDOMAIN TAKEOVER:${NC}\n"
                printf "${GREEN}${BOLD}----------------------------${NC}\n\n"

		for palavra in $(cat /usr/share/dnsrecon/subdomains-top1mil.txt);
		do
			host -t cname $palavra.$specificOption | grep -v "NXDOMAIN" | grep "alias for"
		done
	;;
esac
printf "\n\n${GREEN}${BOLD}SCAN FINALIZADO.\n"
printf "${GREEN}${BOLD}----------------------------${NC}\n\n"
