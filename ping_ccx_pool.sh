#!/bin/bash
################################################################################
# this file is subject to Licence
#Copyright (c) 2023-2024, Acktarius
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
[1,0]="conceal.network" [1,00]="pool." [1,1]="3333" \
[2,0]="cedric-crispin.com" [2,00]="conceal." [2,1]="3364" \
[3,0]="fastpool.xyz" [3,00]="us." [3,01]="eu." [3,02]="sg." [3,1]="10167" \
[4,0]="gntl.uk" [4,00]="ccx." [4,1]="40012" \
[5,0]="conceal.herominers.com" [5,00]="us." [5,01]="au." [5,02]="de." [5,03]="fi." [5,04]="us2." [5,05]="ca." [5,06]="ru." [5,1]="1115" \
[6,0]="hashvault.pro" [6,00]="pool." [6,1]="3333")
#pool list fort zenity
poolZen(){
        for p in {1..6}; do
        echo -e "FALSE $p ${poolAndPort["$p",0]} "
        done
        echo -e "FALSE 7 other "
}
subZenList(){
        echo -e "TRUE 0 ${poolAndPort["$1",00]%*.} "
        s=1
        while  [[ -n "${poolAndPort["$1",0"$s"]}" ]]; do
        echo -e "FALSE $s ${poolAndPort["$1",0"$s"]%*.} "
        ((s++))
        done
        unset s
}
#SubDomain Swapper
subDomainSwapper () {
        poolAndPort["$1",00]=${poolAndPort["$1",0"$2"]}
}
#Zenity SubDomain Swapper

subDomainToSwap(){
local sub=$(zenity --list --radiolist --height 320 --width 400 --title "Pick Subdomain for ${poolAndPort["$1",0]}" --timeout 15 --column "Select" --column "#" --column "SubDomain" $(subZenList $1))
if [[ $1 -eq 3 ]] && [[ $sub -eq 1 ]]; then
#FastPool Europe
poolAndPort[3,00]=""
else
subDomainSwapper $1 $sub
fi

}

#ping pool function
ping_pool () {
artcc=$(nping --tcp -p ${poolAndPort["$1",1]} -c 5 ${poolAndPort["$1",00]}${poolAndPort["$1",0]} | grep "Avg rtt" | cut -d ":" -f 4 | tr -s " " | cut -d "." -f 1 | xargs)
echo "$artcc"
}
#MAIN
presentation
#list
poolZenList=$(poolZen)

sleep 1
list=$(zenity --list --checklist --height 320 --width 400 --title "Pools you want to ping" --timeout 25 --column "Select" --column "#" --column "Pool" $poolZenList)
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
        poolAndPort[7,00]=""
	poolAndPort[7,0]=$xpool
	poolAndPort[7,1]=$xport
        fi
fi

#Subdomain
for j in ${list}; do
        if [[ $j -eq 3 ]]; then
subDomainToSwap $j
        fi
        if [[ $j -eq 5 ]]; then
subDomainToSwap $j

        fi
done

#Pinging
for i in ${list}; do
echo -ne "${GRIS}# running nping for ${ORANGE}${poolAndPort["$i",00]}${poolAndPort["$i",0]}${TURNOFF}\033[0K\r"
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
echo -e "#\t${poolAndPort["$k",2]} ms \t\t${poolAndPort["$k",00]}${poolAndPort["$k",0]}"
done
) | sort -t$'\t' -k2 -n
echo -e "#                                                                  #"
echo -e "${GRIS}####################################################################${TURNOFF}"
echo -e "\n"
unset poolAndPort
#exit
sleep 5
echo -e "press ${WHITE}Ctrl-C${TURNOFF} to exit"
t=0
for t in {0..10}; do
sleep 1
echo -ne "auto exit in $(( 10-${t} )) seconds \033[0K\r"
done
unset t
