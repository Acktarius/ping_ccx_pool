# ping_ccx_pool
*return average response time for selected Conceal mining pool*
### this file is subject to Licence
### Copyright (c) 2023, Acktarius


## this script is delivered “as is” and I deny any and all liability for any damages arising out of using this script

# UBUNTU
## Dependencies
nping is needed, it is ussually part of nmap :

`sudo apt install nmap`

zenity is ussually install on Ubuntu, nevertheless if you want to try this script on other distro, you might need to install it :

`sudo apt install zenity`


# Install
ideally place in the /opt folder, for CCX-BOX user : /opt/conceal-toolbox/ping_ccx_pool/

`cd /opt/conceal-toolbox`

`git clone https://github.com/Acktarius/ping_ccx_pool.git`

`cd ping_ccx_pool`

`sudo chmod 755 ping_ccx_pool.sh`

# Launch in terminal 
`cd /opt/conceal-toolbox/ping_ccx_pool`

`sudo ./ping_ccx_pool.sh` 

# Launch via shortcut and icon,
place icon **pp.png** in ~/.icons

and place **ping_pool.desktop** in ~/.local/share/applications
