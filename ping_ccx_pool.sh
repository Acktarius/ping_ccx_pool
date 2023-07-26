#!/bin/bash
################################################################################
# this file is subject to Licence
#Copyright (c) 2023, Acktarius
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
clear
echo -e "${GRIS}####################################################################"
echo -e "#                                                                  #"
echo -e "${GRIS}###   ${WHITE}          TEST CCX POOLS AVERAGE RESPONSE TIME${TURNOFF}${GRIS}             ###"
echo -e "#                                                                  #"
echo -e "#                                                                  #"
echo -e "####################################################    .::::."
echo -e "#                                                   .:---=--=--::."
echo -e "#${WHITE} Select the pools you 'd like to test,${TURNOFF}${GRIS}\t\t    -=:+-.  .-=:=:"
echo -e "# 					\t    -=:+."
echo -e "# 					\t    -=:+."
echo -e "#                                                   -=:+."
echo -e "#						    -=:=."
echo -e "#                                                   -+:-:    .::."
echo -e "#						    -+==------===-"
echo -e "####################################################   :-=-==-:${TURNOFF}\n"

#Test nping available
if [[ ! -f /bin/nping ]]; then
echo -e "${ORANGE}NPING is needed for this script${GRIS}\nto install it: ${WHITE}sudo apt install nmap${TURNOFF}\n"
exit
fi
#Test zenity available
if [[ ! -f /bin/zenity ]]; then
echo -e "${ORANGE}Zenity is needed for this script${GRIS}\nto install it: ${WHITE}sudo apt install zenity${TURNOFF}\n"
exit
fi

#pools list
pools=("pool.conceal.network" "3333" "conceal.cedric-crispin.com" "3364" "ccx.gntl.uk" "10012" "us.conceal.herominers.com" "1115" "pool.hashvault.pro" "3333")
#ping pool function
ping_pool () {
artcc=$(nping --tcp -p ${pools[ $(( $1 + 1 )) ]} -c 5 ${pools[$1]} | grep "Avg rtt" | cut -d ":" -f 4 | tr -s " " | cut -d "." -f 1 | xargs)
echo "$artcc"
}

#list
sleep 1
list=$(zenity --list --checklist --height 320 --width 400 --title "Pools you want to ping" --column "Select" --column "#" --column "Pool" --column "port" \
FALSE 1 pool.conceal.network 3333 \
FALSE 2 conceal.cedric-crispin.com 3364 \
FALSE 3 ccx.gntl.uk 10012 \
FALSE 4 us.conceal.herominers.com 1115 \
FALSE 5 pool.hashvault.pro 3333 \
FALSE 6 other xxxx \
)

#test if nothing has been done
if [[ $? -eq 1 ]] || [[ $list -eq "" ]]; then
echo "no pool selected"
sleep 1
clear
exit
fi
#check if other has been checked and add it to pools as needed
last=$(( ${#list} - 1 ))
if [[ "${list:$last:1}" = "6" ]]; then
extrapool=$(zenity --forms --separator " " --height 320 --width 400 --text "other pool" --add-entry "Pool address" --add-entry "port")
xpool=$(cut -d " " -f 1 <<< $extrapool)
xport=$(cut -d " " -f 2 <<< $extrapool)
if [[ $xpool != *"."* ]] || [[ ! $xport =~ ^-?[0-9]+$ ]]; then
zenity --error --height 320 --width 400 --title Error --text "pool address doesn't seems right"
sleep 2
clear
exit
else
		pools[${#pools[@]}]=$xpool
		pools[${#pools[@]}]=$xport
fi
fi

#Pinging
declare -a results
i=0
while [[ i -le ${#list} ]]
do
x=$(( 2 * ${list:$i:1} - 2 ))
echo -ne "${GRIS}# running test for ${ORANGE}${pools[$x]}${TURNOFF}\033[0K\r"
results+=($(ping_pool $x)":"${pools[$x]})
sleep 1
i=$(( i+2 ))
done
unset i

#Results
echo -e "${GRIS}#                                                                  #"
echo -e "#                                                                  #"
echo -e "${GRIS}#${WHITE}           Average response time for the pools selected${TURNOFF}${GRIS}           #"
echo -e "#                                                                  #"
#Sorting
(
for k in "${!results[@]}"
do
R=$(echo "${results[$k]}" | cut -d ":" -f 2)
T=$(echo "${results[$k]}" | cut -d ":" -f 1)
echo -e "\t$T ms \t\t$R"
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
exit 0