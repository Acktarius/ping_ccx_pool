#!/bin/bash
################################################################################
# this file is subject to Licence
#Copyright (c) 2023-2024 Acktarius
################################################################################
#Couleurs
case "$TERM" in
        xterm-256color)
        WHITE=$(tput setaf 7 bold)
        ORANGE=$(tput setaf 202)
        GRIS=$(tput setaf 245)
	LINK=$(tput setaf 4 smul)
        TURNOFF=$(tput sgr0)
        ;;
        *)
        WHITE=''
	ORANGE=''
        GRIS=''
	LINK=''
        TURNOFF=''
        ;;
esac
#Presentation
presentation (){
clear
echo -e "${GRIS}####################################################################"
echo -e "#                                                                  #"
echo -e "${GRIS}###   ${WHITE}          TEST CCX POOLS AVERAGE RESPONSE TIME${TURNOFF}${GRIS}               #"
echo -e "#                                                                  #"
echo -e "#                                                                  #"
echo -e "####################################################    ${WHITE}.::::."
echo -e "${GRIS}#                                                   ${WHITE}.:---=--=--::."
echo -e "#${WHITE} Select the pools you 'd like to test,\t\t    -=:+-.  .-=:=:"
echo -e "${GRIS}# 					\t    ${WHITE}-=:+."
echo -e "${GRIS}# 					\t    ${WHITE}-=:+."
echo -e "${GRIS}#                                                   ${WHITE}-=:+."
echo -e "${GRIS}#						    ${WHITE}-=:=."
echo -e "${GRIS}#                                                   ${WHITE}-+:-:    .::."
echo -e "${GRIS}#						    ${WHITE}-+==------===-"
echo -e "${GRIS}####################################################   ${WHITE}:-=-==-:${TURNOFF}\n"
}
#Test nping available
if ! command -v nping &> /dev/null; then
echo -e "${ORANGE}NPING is needed for this script${GRIS}\nto install it: ${WHITE}sudo apt install nmap${TURNOFF}\n"
exit
fi
#Test zenity available
if ! command -v zenity &> /dev/null; then
echo -e "${ORANGE}Zenity is needed for this script${GRIS}\nto install it: ${WHITE}sudo apt install zenity${TURNOFF}\n"
exit
fi

#pools list
declare -A poolAndPort=(
[1,0]="pool.conceal.network" [1,1]="3333" \
[2,0]="conceal.cedric-crispin.com" [2,1]="3364" \
[3,0]="us.fastpool.xyz" [3,1]="10167" \
[4,0]="ccx.gntl.uk" [4,1]="40012" \
[5,0]="us.conceal.herominers.com" [5,1]="1115" \
[6,0]="pool.hashvault.pro" [6,1]="3333")

#ping pool function
ping_pool () {
artcc=$(nping --tcp -p ${poolAndPort["$1",1]} -c 5 ${poolAndPort["$1",0]} | grep "Avg rtt" | cut -d ":" -f 4 | tr -s " " | cut -d "." -f 1 | xargs)
echo "$artcc"
}

presentation
#list
sleep 1
list=$(zenity --list --checklist --height 320 --width 400 --title "Pools you want to ping" --timeout 25 --column "Select" --column "#" --column "Pool" --column "port" \
FALSE 1 pool.conceal.network 3333 \
FALSE 2 conceal.cedric-crispin.com 3364 \
FALSE 3 us.fastpool.xyz 10167 \
FALSE 4 ccx.gntl.uk xxxxx \
FALSE 5 us.conceal.herominers.com 1115 \
FALSE 6 pool.hashvault.pro 3333 \
FALSE 7 other xxxx \
)
list=$(echo "$list" | tr "|" " ")
#test if nothing has been done
if [[ $? -eq 1 ]] || [[ -z $list ]]; then
echo "no pool selected"
sleep 1
clear
exit
fi
#check if other has been checked and add it to pools as needed
if [[ "${list:(-1)}" = "7" ]]; then
extrapool=$(zenity --forms --separator " " --height 320 --width 400 --text "other pool" --add-entry "Pool address" --add-entry "port")
xpool=$(cut -d " " -f 1 <<< $extrapool)
xport=$(cut -d " " -f 2 <<< $extrapool)
        if [[ $xpool != *"."* ]] || [[ ! $xport =~ ^-?[0-9]+$ ]]; then
        zenity --error --height 320 --width 400 --title Error --text "pool address doesn't seems right"
        sleep 2
        clear
        exit
        else
	poolAndPort[7,0]=$xpool
	poolAndPort[7,1]=$xport
        fi
fi

#Pinging
for i in ${list}; do
echo -ne "${GRIS}# running nping for ${ORANGE}${poolAndPort["$i",0]}${TURNOFF}\033[0K\r"
poolAndPort["$i",2]="$(ping_pool $i)"
sleep 1
done
unset i

#Results
echo -e "${GRIS}#                                                                  #"
echo -e "#                                                                  #"
echo -e "${GRIS}#${WHITE}           Average response time for the pools selected${TURNOFF}${GRIS}           #"
echo -e "#                                                                  #"
#Sorting
(
for k in ${list}; do
echo -e "#\t${poolAndPort["$k",2]} ms \t\t${poolAndPort["$k",0]}"
done
) | sort -t$'\t' -k2 -n
echo -e "#                                                                  #"
echo -e "${GRIS}####################################################################${TURNOFF}"
echo -e "\n"
unset results
#exit
sleep 5
echo -e "press ${WHITE}Ctrl-C${TURNOFF} to exit"
t=0
for t in {0..10}; do
sleep 1
echo -ne "auto exit in $(( 10-${t} )) seconds \033[0K\r"
done
unset t
