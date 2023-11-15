#**************************************************************************
# Identificacion: Endurecimiento_SO-DGTI.sh
# Version: 1.2
# Nombre del proyecto: Kubernetes VM SFP
# Instalacion: DGTI
# Fecha de creacion: 30/04/2021
# Fecha de ultima actualizacion: 09/09/2023
# Elaboro: Gonzalez Flores Byron
#
# NOTA: Los comandos deben de ser ejecutados como superusuario
#
#**************************************************************************
#!/bin/bash

echo "==================================="
echo "=      Endurecimiento del SO      ="
echo "==================================="


echo ================= 1.1.18,19,20 ================= 

#revisar que no haya noexec, nodev, nosuid en /dev
mount


echo ================= 1.1.21 ================= 

VARIABLE="df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "" ]]; then
        df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' chmod a+t '{}'
        echo "OK"
else
        echo "No sticky bit OK"
fi


echo ================= 1.1.22 ================= 

VARIABLE="systemctl is-enabled autofs"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "disabled" ]]; then
        systemctl --now disable autofs
        echo "OK change"
else
        echo "OK"
fi


echo ================= 1.1.23 ================= 

VARIABLE="modprobe -n -v usb-storage"
VARIABLE=$(eval "$VARIABLE")

VARIABLE1="lsmod | grep usb-storage"
VARIABLE1=$(eval "$VARIABLE1")

if [[ $VARIABLE =~ "/bin/true" ]] && [[ VARIABLE1 = "" ]] ; then
        echo "OK"
else
        echo "install usb-storage /bin/true" >> /etc/modprobe.d/usb-storage.conf
        rmmod usb-storage
        echo "OK"
fi


echo ================= 1.2.1 ================= 
apt-cache policy



echo ================= 1.2.2 ================= 

#Configuracion del repolist
#VARIABLE="grep ^gpgcheck /etc/yum.conf"
#VARIABLE=$(eval "$VARIABLE")

#if [[ $VARIABLE != "gpgcheck=1" ]]; then
#        sed -i 's/gpgcheck.*/gpgcheck=1/g' /etc/yum.conf
#        echo "Change OK"
#else
#        echo "OK"       
#fi


echo ================= 1.3.1 =================
VARIABLE="dpkg -s sudo"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        apt install sudo
        echo "Sudo Intalled OK"
else
        echo "OK"
fi


echo ================= 1.3.2 =================
VARIABLE="grep -Ei '^\s*Defaults\s+(\[^#]+,\s*)?use_pty' /etc/sudoers /etc/sudoers.d/*"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "Defaults use_pty" ]]; then
        echo 'Defaults use_pty' >> /etc/sudoers
        echo "OK"
else
        echo "No pty OK"
fi



echo ================= 1.3.3 =================

VARIABLE="grep -Ei '^\s*Defaults\s+([^#]+,\s*)?logfile=' /etc/sudoers /etc/sudoers.d/*"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "/var/log/sudo.log" ]]; then
        echo 'Defaults logfile="/var/log/sudo.log"' >> /etc/sudoers
        echo "OK log conf"
else
        echo "OK log"
fi


echo ================= 1.5.1 ================= 

chown root:root /boot/grub/grub.cfg
chmod og-rwx /boot/grub/grub.cfg



echo ================= 1.8.1.1 ================= 

#cp /etc/motd /etc/motd.bkp
#cat /etc/ssh/banner_banner3-D > /etc/motd
#Identificar headears del login
echo "Esta usted intentando acceder a un sistema informático de acceso restringido. La actividad asociada a este sistema es monitoreada permanentemente.  Todo intento de acceso no autorizado será considerado una violación a la legislación vigente  y será reportado a las autoridades correspondientes" > /etc/motd

echo ================= 1.8.1.2 ================= 

#cp /etc/issue /etc/issue.bkp
#cat /etc/ssh/banner_banner3-D > /etc/issue
echo "Esta usted intentando acceder a un sistema informático de acceso restringido. La actividad asociada a este sistema es monitoreada permanentemente. Todo intento de acceso no autorizado será considerado una violación a la legislación vigente y será reportado a las autoridades correspondientes" > /etc/issue


echo ================= 1.8.1.3 ================= 

#cp /etc/issue.net /etc/issue.net.bkp
#cat /etc/ssh/banner_banner3-D > /etc/issue.net
echo "Esta usted intentando acceder a un sistema informático de acceso restringido. La actividad asociada a este sistema es monitoreada permanentemente. Todo intento de acceso no autorizado será considerado una violación a la legislación vigente y será reportado a las autoridades correspondientes" > /etc/issue.net

echo ================= 1.8.1.4 ================= 
chown root:root /etc/motd
chmod u-x,go-wx /etc/motd
echo "OK"


echo ================= 1.8.1.5 ================= 
chown root:root /etc/issue
chmod u-x,go-wx /etc/issue
echo "OK"


echo ================= 1.8.1.6 ================= 
chown root:root /etc/issue.net
chmod u-x,go-wx /etc/issue.net
echo "OK"


echo ================= 1.9 =================  

echo "[org/gnome/login-screen]" >> /etc/gdm3/greeter.dconf-defaults
echo "banner-message-enable=true" >> /etc/gdm3/greeter.dconf-defaults
echo "banner-message-text='GDM no disponible'" >> /etc/gdm3/greeter.dconf-defaults
echo "disable-user-list=true" >> /etc/gdm3/greeter.dconf-defaults

dpkg-reconfigure gdm3


echo ================= 1.10 =================  

apt -s upgrade



echo ================= 2.1.1.1, 2.1.1.2  ================= 
VARIABLE="dpkg -s ntp"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK not installed"
else
        apt -y install ntp
        apt purge chrony -y
        systemctl --now mask systemd-timesyncd
        systemctl is-enabled systemd-timesyncd.service
        echo "restrict -4 default kod nomodify notrap nopeer noquery" >> /etc/ntp.conf
        echo "restrict -6 default kod nomodify notrap nopeer noquery" >> /etc/ntp.conf
        echo "server cronos.cenam.mx" >> /etc/ntp.conf
        echo "RUNASUSER=ntp" >> /etc/ntp.conf
        service ntp restart
        echo "OK install"
fi



echo ================= 2.1.2 ================= 
VARIABLE="dpkg -l xserver-xorg*"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "" ]]; then
        echo "OK not installed"
else
        apt purge xserver-xorg* -y
        echo "OK removed"
fi


echo ================= 2.1.3 ================= 

VARIABLE="dpkg -s avahi-daemon"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
systemctl stop avahi-daaemon.service
systemctl stop avahi-daemon.socket
apt purge -y avahi-daemon       
echo "OK disabled now"
fi


echo ================= 2.1.5 ================= 

VARIABLE="dpkg -s isc-dhcp-server"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge isc-dhcp-server -y
echo "OK disabled now"
fi


echo ================= 2.1.6 ================= 

VARIABLE="dpkg -s slapd"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge slapd -y
echo "OK disabled now"
fi


echo ================= 2.1.7 ================= 

VARIABLE="dpkg -s nfs-kernel-server"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge nfs-kernel-server     -y
echo "OK disabled now"
fi


echo ================= 2.1.8 ================= 

VARIABLE="dpkg -s bind9"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge bind9 -y
echo "OK disabled now"
fi


echo ================= 2.1.9 ================= 

VARIABLE="dpkg -s vsftpd"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge vsftpd -y
echo "OK disabled now"
fi


echo ================= 2.1.11 ================= 

VARIABLE="dpkg -s dovecot-imapd dovecot-pop3d"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge dovecot-imapd dovecot-pop3d   
echo "OK disabled now"
fi


echo ================= 2.1.12 ================= 

VARIABLE="dpkg -s samba"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge samba -y
echo "OK disabled now"
fi



echo ================= 2.1.13 ================= 

VARIABLE="dpkg -s squid"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge squid -y
echo "OK disabled now"
fi


echo ================= 2.1.15 ================= 

VARIABLE="ss -lntu | grep -E ':25\s' | grep -E -v '\s(127.0.0.1|::1):25\s'"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "" ]]; then
mv /etc/exim4/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf.bkp
cat > /etc/exim4/update-exim4.conf.conf << "EOF"
dc_eximconfig_configtype='local'
dc_local_interfaces='127.0.0.1 ; ::1'
dc_readhost=''
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets=''
dc_smarthost=''
dc_use_split_config='false'
dc_hide_mailname=''
dc_mailname_in_oh='true'
dc_localdelivery='mail_spool'
EOF
systemctl restart exim4
else
        echo "OK disabled now"
fi



echo ================= 2.1.16 ================= 

VARIABLE="dpkg -s rsync"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge rsync -y
echo "OK disabled now"
fi


echo ================= 2.1.17,  2.2.1 ================= 

VARIABLE="dpkg -s nis"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge nis   
echo "OK disabled now"
fi



echo ================= 2.2.2 ================= 

VARIABLE="dpkg -s rsh-client"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge rsh-client    
echo "OK disabled now"
fi

echo ================= 2.2.3 ================= 

VARIABLE="dpkg -s talk"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge talk  
echo "OK disabled now"
fi


#echo ================= 2.2.4 ================= 

#VARIABLE="dpkg -s telnet"
#VARIABLE=$(eval "$VARIABLE")

#if [[ $VARIABLE =~ "not installed" ]]; then
#        echo "OK disabled"
#else
#apt purge telnet -y
#echo "OK disabled now"
#fi


echo ================= 2.2.5 ================= 

VARIABLE="dpkg -s ldap-utils"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge ldap-utils    
echo "OK disabled now"
fi


echo ================= 2.2.6 ================= 

VARIABLE="dpkg -s rpcbind"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge rpcbind -y
echo "OK disabled now"
fi


echo ================= 2.3 =================

lsof -i -P -n | grep -v "(ESTABLISHED)"



# echo ================= 3.1.1 ================= 

# VARIABLE="sysctl net.ipv4.ip_forward"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="grep -E -s \"^\s*net\.ipv4\.ip_forward\s*=\s*1\" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf"
# VARIABLE1=$(eval "$VARIABLE1")

# VARIABLE2="sysctl net.ipv6.conf.all.forwarding"
# VARIABLE2=$(eval "$VARIABLE2")

# VARIABLE3="grep -E -s \"^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*1\" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf"
# VARIABLE3=$(eval "$VARIABLE3")

# if [[ $VARIABLE != "net.ipv4.ip_forward = 0" ]] || [[ $VARIABLE1 != "" ]] || [[ $VARIABLE2 != "net.ipv6.conf.all.forwarding = 0" ]] || [[ $VARIABLE3 != "" ]]; then
#         grep -Els "^\s*net\.ipv4\.ip_forward\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read filename; do sed -ri "s/^\s*(net\.ipv4\.ip_forward\s*)(=)(\s*\S+\b).*$/# *REMOVED* \1/" $filename; done; sysctl -w net.ipv4.ip_forward=0; sysctl -w net.ipv4.route.flush=1
#         grep -Els "^\s*net\.ipv6\.conf\.all\.forwarding\s*=\s*1" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read filename; do sed -ri "s/^\s*(net\.ipv6\.conf\.all\.forwarding\s*)(=)(\s*\S+\b).*$/# *REMOVED* \1/" $filename; done; sysctl -w net.ipv6.conf.all.forwarding=0; sysctl -w net.ipv6.route.flush=1
#         echo "OK"
# else
#         echo "OK "
# fi


# echo ================= 3.1.2 ================= 

# VARIABLE="sysctl net.ipv4.conf.all.send_redirects"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="sysctl net.ipv4.conf.default.send_redirects"
# VARIABLE1=$(eval "$VARIABLE1")

# VARIABLE2="grep \"net\.ipv4\.conf\.all\.send_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE2=$(eval "$VARIABLE2")

# VARIABLE3="grep \"net\.ipv4\.conf\.default\.send_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE3=$(eval "$VARIABLE3")

# if [[ $VARIABLE != "net.ipv4.conf.all.send_redirects = 0" ]] || [[ $VARIABLE1 != "net.ipv4.conf.default.send_redirects = 0" ]] || [[ $VARIABLE2 != "net.ipv4.conf.all.send_redirects = 0" ]] || [[ $VARIABLE3 != "net.ipv4.conf.default.send_redirects= 0" ]]; then
#         echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
#         echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
#         sysctl -w net.ipv4.conf.all.send_redirects=0 
#         sysctl -w net.ipv4.conf.default.send_redirects=0 
#         sysctl -w net.ipv4.route.flush=1
#         echo "OK change"
# else
#         echo "OK "
# fi



# echo ================= 3.2.1 ================= 

# VARIABLE="sysctl net.ipv4.conf.all.accept_source_route"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="sysctl net.ipv4.conf.default.accept_source_route"
# VARIABLE1=$(eval "$VARIABLE1")

# VARIABLE2="grep \"net\.ipv4\.conf\.all\.accept_source_route\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE2=$(eval "$VARIABLE2")

# VARIABLE3="grep \"net\.ipv4\.conf\.default\.accept_source_route\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE3=$(eval "$VARIABLE3")

# VARIABLE4="sysctl net.ipv6.conf.all.accept_source_route"
# VARIABLE4=$(eval "$VARIABLE4")

# VARIABLE5="sysctl net.ipv6.conf.default.accept_source_route"
# VARIABLE5=$(eval "$VARIABLE5")

# VARIABLE6="grep \"net\.ipv6\.conf\.all\.accept_source_route\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE6=$(eval "$VARIABLE6")

# VARIABLE7="grep \"net\.ipv6\.conf\.default\.accept_source_route\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE7=$(eval "$VARIABLE7")

# if [[ $VARIABLE != "net.ipv4.conf.all.accept_source_route = 0" ]] || [[ $VARIABLE1 != "net.ipv4.conf.default.accept_source_route = 0" ]] || [[ $VARIABLE2 != "net.ipv4.conf.all.accept_source_route= 0" ]] || [[ $VARIABLE3 != "net.ipv4.conf.default.accept_source_route= 0" ]] || [[ $VARIABLE4 != "net.ipv6.conf.all.accept_source_route = 0" ]] || [[ $VARIABLE5 != "net.ipv6.conf.default.accept_source_route = 0" ]] || [[ $VARIABLE6 != "net.ipv4.conf.all.accept_source_route= 0" ]] || [[ $VARIABLE7 != "net.ipv6.conf.default.accept_source_route= 0" ]]; then
#         echo "net.ipv4.conf.all.accept_source_route = 0 " >> /etc/sysctl.conf
#         echo "net.ipv4.conf.default.accept_source_route = 0 " >> /etc/sysctl.conf
#         echo "net.ipv6.conf.all.accept_source_route = 0 " >> /etc/sysctl.conf
#         echo "net.ipv6.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
#         sysctl -w net.ipv4.conf.all.accept_source_route=0 
#         sysctl -w net.ipv4.conf.default.accept_source_route=0 
#         sysctl -w net.ipv6.conf.all.accept_source_route=0 
#         sysctl -w net.ipv6.conf.default.accept_source_route=0
#         sysctl -w net.ipv4.route.flush=1
#         sysctl -w net.ipv6.route.flush=1
#         echo "OK change"
# else
#         echo "OK "
# fi


# echo ================= 3.2.2 ================= 

# VARIABLE="sysctl net.ipv4.conf.all.accept_redirects"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="sysctl net.ipv4.conf.default.accept_redirects"
# VARIABLE1=$(eval "$VARIABLE1")

# VARIABLE2="grep \"net\.ipv4\.conf\.all\.accept_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE2=$(eval "$VARIABLE2")

# VARIABLE3="grep \"net\.ipv4\.conf\.default\.accept_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE3=$(eval "$VARIABLE3")

# VARIABLE4="sysctl net.ipv6.conf.all.accept_redirects"
# VARIABLE4=$(eval "$VARIABLE4")

# VARIABLE5="sysctl net.ipv6.conf.default.accept_redirects"
# VARIABLE5=$(eval "$VARIABLE5")

# VARIABLE6="grep \"net\.ipv6\.conf\.all\.accept_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE6=$(eval "$VARIABLE6")

# VARIABLE7="grep \"net\.ipv6\.conf\.default\.accept_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE7=$(eval "$VARIABLE7")

# if [[ $VARIABLE != "net.ipv4.conf.all.accept_redirects = 0" ]] || [[ $VARIABLE1 != "net.ipv4.conf.default.accept_redirects = 0" ]] || [[ $VARIABLE2 != "net.ipv4.conf.all.accept_redirects= 0" ]] || [[ $VARIABLE3 != "net.ipv4.conf.default.accept_redirects= 0" ]] || [[ $VARIABLE4 != "net.ipv6.conf.all.accept_redirects = 0" ]] || [[ $VARIABLE5 != "net.ipv6.conf.default.accept_redirects = 0" ]] || [[ $VARIABLE6 != "net.ipv6.conf.all.accept_redirects= 0" ]] || [[ $VARIABLE7 != "net.ipv6.conf.default.accept_redirects= 0" ]]; then
#         echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf 
#         echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf 
#         echo "net.ipv6.conf.all.accept_redirects = 0" >> /etc/sysctl.conf 
#         echo "net.ipv6.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
#         sysctl -w net.ipv4.conf.all.accept_redirects=0 
#         sysctl -w net.ipv4.conf.default.accept_redirects=0 
#         sysctl -w net.ipv6.conf.all.accept_redirects=0 
#         sysctl -w net.ipv6.conf.default.accept_redirects=0
#         sysctl -w net.ipv4.route.flush=1
#         sysctl -w net.ipv6.route.flush=1
#         echo "OK change"
# else
#         echo "OK "
# fi


# echo ================= 3.2.3 ================= 

# VARIABLE="sysctl net.ipv4.conf.all.secure_redirects"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="sysctl net.ipv4.conf.default.secure_redirects"
# VARIABLE1=$(eval "$VARIABLE1")

# VARIABLE2="grep \"net\.ipv4\.conf\.all\.secure_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE2=$(eval "$VARIABLE2")

# VARIABLE3="grep \"net\.ipv4\.conf\.default\.secure_redirects\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE3=$(eval "$VARIABLE3")

# if [[ $VARIABLE != "net.ipv4.conf.all.secure_redirects = 0" ]] || [[ $VARIABLE1 != "net.ipv4.conf.default.secure_redirects = 0" ]] || [[ $VARIABLE2 != "net.ipv4.conf.all.secure_redirects= 0" ]] || [[ $VARIABLE3 != "net.ipv4.conf.default.secure_redirects= 0" ]]; then
#         echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf 
#         echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf
#         sysctl -w net.ipv4.conf.all.secure_redirects=0
#         sysctl -w net.ipv4.conf.default.secure_redirects=0 
#         sysctl -w net.ipv4.route.flush=1
#         echo "OK change"
# else
#         echo "OK "
# fi


# echo ================= 3.2.4================= 

# VARIABLE="sysctl net.ipv4.conf.all.log_martians"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="sysctl net.ipv4.conf.default.log_martians"
# VARIABLE1=$(eval "$VARIABLE1")

# VARIABLE2="grep \"net\.ipv4\.conf\.all\.log_martians\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE2=$(eval "$VARIABLE2")

# VARIABLE3="grep \"net\.ipv4\.conf\.default\.log_martians\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE3=$(eval "$VARIABLE3")

# if [[ $VARIABLE != "net.ipv4.conf.all.log_martians = 1" ]] || [[ $VARIABLE1 != "net.ipv4.conf.default.log_martians = 1" ]] || [[ $VARIABLE2 != "net.ipv4.conf.all.log_martians = 1" ]] || [[ $VARIABLE3 != "net.ipv4.conf.default.log_martians = 1" ]]; then
#         echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf 
#         echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
#         sysctl -w net.ipv4.conf.all.log_martians=1
#         sysctl -w net.ipv4.conf.default.log_martians=1
#         sysctl -w net.ipv4.route.flush=1
#         echo "OK change"
# else
#         echo "OK "
# fi



# echo ================= 3.2.7 ================= 

# VARIABLE="sysctl net.ipv4.conf.all.rp_filter"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="sysctl net.ipv4.conf.default.rp_filt"
# VARIABLE1=$(eval "$VARIABLE1")

# VARIABLE2="grep -E -s \"^\s*net\.ipv4\.conf\.all\.rp_filter\s*=\s*0\" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf"
# VARIABLE2=$(eval "$VARIABLE2")

# VARIABLE3="grep -E -s \"^\s*net\.ipv4\.conf\.default\.rp_filter\s*=\s*1\" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf"
# VARIABLE3=$(eval "$VARIABLE3")

# if [[ $VARIABLE != "net.ipv4.conf.all.rp_filter = 1" ]] || [[ $VARIABLE1 != "net.ipv4.conf.default.rp_filter = 1" ]] || [[ $VARIABLE2 != "" ]] || [[ $VARIABLE3 != "net.ipv4.conf.default.rp_filter = 1" ]]; then
#         grep -Els "^\s*net\.ipv4\.conf\.all\.rp_filter\s*=\s*0" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read filename; do sed -ri "s/^\s*(net\.ipv4\.net.ipv4.conf\.all\.rp_filter\s*)(=)(\s*\S+\b).*$/# *REMOVED* \1/" $filename; done; sysctl -w net.ipv4.conf.all.rp_filter=1; sysctl -w net.ipv4.route.flush=1
#         echo "net.ipv4.conf.default.rp_filter=1" >> /etc/sysctl.conf
#         sysctl -w net.ipv4.conf.default.rp_filter=1 
#         sysctl -w net.ipv4.route.flush=1
#         echo "OK change"
# else
#         echo "OK "
# fi



# echo ================= 3.2.8 ================= 

# VARIABLE="sysctl net.ipv4.tcp_syncookies"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="grep -E -r \"^\s*net\.ipv4\.tcp_syncookies\s*=\s*[02]\" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf"
# VARIABLE1=$(eval "$VARIABLE1")


# if [[ $VARIABLE != "net.ipv4.tcp_syncookies = 1" ]] || [[ $VARIABLE1 != "" ]]; then
#         grep -Els "^\s*net\.ipv4\.tcp_syncookies\s*=\s*[02]*" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf | while read filename; do sed -ri "s/^\s*(net\.ipv4\.tcp_syncookies\s*)(=)(\s*\S+\b).*$/# *REMOVED* \1/" $filename; done; sysctl -w net.ipv4.tcp_syncookies=1; sysctl -w net.ipv4.route.flush=1
#         echo "OK change"
# else
#         echo "OK "
# fi



# echo ================= 3.2.9 ================= 

# VARIABLE="sysctl net.ipv6.conf.all.accept_ra"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="sysctl net.ipv6.conf.default.accept_ra"
# VARIABLE1=$(eval "$VARIABLE1")

# VARIABLE2="grep \"net\.ipv6\.conf\.all\.accept_ra\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE2=$(eval "$VARIABLE2")

# VARIABLE3="grep \"net\.ipv6\.conf\.default\.accept_ra\" /etc/sysctl.conf /etc/sysctl.d/*"
# VARIABLE3=$(eval "$VARIABLE3")

# if [[ $VARIABLE != "net.ipv6.conf.all.accept_ra = 0" ]] || [[ $VARIABLE1 != "net.ipv6.conf.default.accept_ra = 0" ]] || [[ $VARIABLE2 != "net.ipv6.conf.all.accept_ra = 0" ]] || [[ $VARIABLE3 != "net.ipv6.conf.default.accept_ra = 0" ]]; then
#         echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf
#         echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf
#         sysctl -w net.ipv6.conf.all.accept_ra=0 # 
#         sysctl -w net.ipv6.conf.default.accept_ra=0
#         sysctl -w net.ipv6.route.flush=1
#         echo "OK change"
# else
#         echo "OK "
# fi



# echo ================= 3.5.1 ================= 
# VARIABLE="modprobe -n -v dccp"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="lsmod | grep dccp"
# VARIABLE1=$(eval "$VARIABLE1")

# if [[ $VARIABLE =~ "install /bin/true" ]] || [[ $VARIABLE1 != "" ]]; then
#         echo "install dccp /bin/true" > /etc/modprobe.d/dccp.conf
#         echo "OK disabled"
# else
#         echo "OK"
# fi


# echo ================= 3.5.2 ================= 
# VARIABLE="modprobe -n -v sctp"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="lsmod | grep sctp"
# VARIABLE1=$(eval "$VARIABLE1")

# if [[ $VARIABLE =~ "install /bin/true" ]] || [[ $VARIABLE1 != "" ]]; then
#         echo "install sctp /bin/true" > /etc/modprobe.d/sctp.conf
#         echo "OK disabled"
# else
#         echo "OK"
# fi


# echo ================= 3.5.3 ================= 
# VARIABLE="modprobe -n -v rds"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="lsmod | grep rds"
# VARIABLE1=$(eval "$VARIABLE1")

# if [[ $VARIABLE =~ "install /bin/true" ]] || [[ $VARIABLE1 != "" ]]; then
#         echo "install rds /bin/true" > /etc/modprobe.d/rds.conf
#         echo "OK disabled"
# else
#         echo "OK"
# fi


# echo ================= 3.5.4 ================= 
# VARIABLE="modprobe -n -v tipc"
# VARIABLE=$(eval "$VARIABLE")

# VARIABLE1="lsmod | grep tipc"
# VARIABLE1=$(eval "$VARIABLE1")

# if [[ $VARIABLE =~ "install /bin/true" ]] || [[ $VARIABLE1 != "" ]]; then
#         echo "install tipc /bin/true" > /etc/modprobe.d/tipc.conf
#         echo "OK disabled"
# else
#         echo "OK"
# fi


echo ================= 3.4.1.1 ================= 

VARIABLE=$(dpkg -s iptables)

if [[ $VARIABLE =~ "not installed" ]]; then
        apt -y install iptables
        echo "OK"
else
        echo "OK install"
fi


echo ================= 3.5 ========  
VARIABLE="nmcli radio all"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "enabled disabled enabled disabled" ]]; then
        nmcli radio all off
        echo "OK disable"
else
        echo "OK"
fi



echo ================= 4.1.1.1 ========  

VARIABLE="dpkg -s auditd audispd-plugins"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        apt -y install auditd audispd-plugins
        echo "OK"
fi


echo ================= 4.1.1.2 ========  

VARIABLE="systemctl is-enabled auditd"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "enabled" ]]; then
        systemctl --now enable auditd
        echo "OK"
fi


# echo ================= 3.6, 4.1.1.3, 4.1.1.4 ========  
# VARIABLE1=$(grep -E "^\s*kernelopts=(\S+\s+)*ipv6\.disable=1\b\s*(\S+\s*)*$" /boot/grub2/grubenv)
# VARIABLE2=$(grep -E 'kernelopts=(\S+\s+)*audit=1\b' /boot/grub2/grubenv)
# VARIABLE3=$(grep -E 'kernelopts=(\S+\s+)*audit_backlog_limit=\S+\b' /boot/grub2/grubenv)

# if [[ $VARIABLE1 != "ipv6.disable=1" ]] || [[ $VARIABLE2 != "audit=1" ]] || [[ $VARIABLE != "audit_backlog_limit=32768" ]]; then
#         sed -i 's/GRUB_CMDLINE_LINUX.*/GRUB_CMDLINE_LINUX="ipv6.disable=1 audit=1 audit_backlog_limit=32768"/g' /etc/default/grub
#         grub2-mkconfig –o /boot/grub2/grub.cfg
#         echo "OK chage"
# else
#         echo "OK"
# fi



echo ================= 4.1.2.1 ========  
VARIABLE=$(grep max_log_file /etc/audit/auditd.conf )

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "max_log_file = 16" ]]; then
                sed -i 's/max_log_file = 8/max_log_file = 16/g' /etc/audit/auditd.conf
                echo "OK change"
        else
                echo "max_log_file = 16" >> /etc/audit/auditd.conf
                echo "OK"
        fi
else
        echo "max_log_file = 16" >> /etc/audit/auditd.conf
        echo "OK"
fi



echo ================= 4.1.2.2 ======== 

VARIABLE=$(grep max_log_file_action /etc/audit/auditd.conf )

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "max_log_file_action = keep_logs" ]]; then
                sed -i 's/max_log_file_action/#max_log_file_action"/g' /etc/audit/auditd.conf
                echo "max_log_file_action = keep_logs" >> /etc/audit/auditd.conf
                echo "OK change"
        else
                echo "max_log_file_action = keep_logs" >> /etc/audit/auditd.conf
                echo "OK"
        fi
else
        echo "max_log_file_action = keep_logs" >> /etc/audit/auditd.conf
        echo "OK"
fi


echo ================= 4.1.2.3 ======== 

VARIABLE="grep space_left_action /etc/audit/auditd.conf"
VARIABLE=$(eval "$VARIABLE")

VARIABLE1="grep action_mail_acct /etc/audit/auditd.conf"
VARIABLE1=$(eval "$VARIABLE1")

VARIABLE2="grep admin_space_left_action /etc/audit/auditd.conf"
VARIABLE2=$(eval "$VARIABLE2")



if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "space_left_action = email" ]]; then
                sed -i 's/space_left_action = SYSLOG/space_left_action = email/g' /etc/audit/auditd.conf
                echo "OK change"
        else
                echo "space_left_action = email" >> /etc/audit/auditd.conf 
                echo "OK"
        fi
else
        echo "space_left_action = email" >> /etc/audit/auditd.conf 
        echo "OK"
fi

if [[ $VARIABLE1 != "" ]]; then
        if [[ $VARIABLE1 != "action_mail_acct = root" ]]; then
                sed -i 's/action_mail_acct*/action_mail_acct = root/g' /etc/audit/auditd.conf
                echo "OK change"
        else
                echo "action_mail_acct = root" >> /etc/audit/auditd.conf 
                echo "OK"
        fi
else
        echo "action_mail_acct = root" >> /etc/audit/auditd.conf 
        echo "OK"
fi

if [[ $VARIABLE2 != "" ]]; then
        if [[ $VARIABLE2 != "admin_space_left_action = halt" ]]; then
                sed -i 's/admin_space_left_action = SUSPEND/admin_space_left_action = halt/g' /etc/audit/auditd.conf
                echo "OK change"
        else
                echo "admin_space_left_action = halt" >> /etc/audit/auditd.conf
                echo "OK"
        fi
else
        echo "admin_space_left_action = halt" >> /etc/audit/auditd.conf
        echo "OK"
fi



echo ================= 4.1.3 ======== 
VARIABLE="grep scope /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-w /etc/sudoers -p wa -k scope" > /etc/audit/rules.d/scope.rules
        echo "-w /etc/sudoers.d/ -p wa -k scope" >> /etc/audit/rules.d/scope.rules
        echo "OK change"
fi



echo ================= 4.1.4 ======== 

VARIABLE="grep logins /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-w /var/log/faillog -p wa -k logins" >> /etc/audit/rules.d/audit.rules 
        echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/rules.d/audit.rules
        echo "OK change"
fi



echo ================= 4.1.5 ======== 

VARIABLE="grep -E '(session|logins)' /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-w /var/run/utmp -p wa -k session" >> /etc/audit/rules.d/logins.rules
        echo "-w /var/log/wtmp -p wa -k logins" >> /etc/audit/rules.d/logins.rules
        echo "-w /var/log/btmp -p wa -k logins" >> /etc/audit/rules.d/logins.rules
        echo "OK change"
fi


echo ================= 4.1.6 ======== 

VARIABLE="grep time-change /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/rules.d/time-change.rules 
        echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/rules.d/time-change.rules 
        echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/rules.d/time-change.rules 
        echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/rules.d/time-change.rules 
        echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/rules.d/time-change.rules
        echo "OK change"
fi


# echo ================= 4.1.7 ======== 

# VARIABLE="grep MAC-policy /etc/audit/rules.d/*.rules"
# VARIABLE=$(eval "$VARIABLE")


# if [[ $VARIABLE != "" ]]; then
#         echo "OK"
# else
#         echo "-w /etc/selinux/ -p wa -k MAC-policy" >> /etc/audit/rules.d/MAC-policy.rules
#         echo "-w /usr/share/selinux/ -p wa -k MAC-policy" >> /etc/audit/rules.d/MAC-policy.rules
#         echo "OK change"
# fi


echo ================= 4.1.8 ======== 

VARIABLE="grep system-locale /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/system-locale.rules
        echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/system-locale.rules 
        echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/rules.d/system-locale.rules 
        echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/rules.d/system-locale.rules 
        echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/rules.d/system-locale.rules 
        echo "-w /etc/sysconfig/network -p wa -k system-locale" >> /etc/audit/rules.d/system-locale.rules
        echo "OK change"
fi



echo ================= 4.1.9 ======== 

VARIABLE="grep perm_mod /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/perm_mod.rules 
        echo "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod " >> /etc/audit/rules.d/perm_mod.rules
        echo "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod " >> /etc/audit/rules.d/perm_mod.rules
        echo "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod " >> /etc/audit/rules.d/perm_mod.rules
        echo "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod " >> /etc/audit/rules.d/perm_mod.rules
        echo "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/perm_mod.rules
        echo "OK change"
fi


echo ================= 4.1.10 ======== 

VARIABLE="grep access /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access " >> /etc/audit/rules.d/access.rules
        echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access " >> /etc/audit/rules.d/access.rules
        echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access " >> /etc/audit/rules.d/access.rules
        echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/access.rules
        echo "OK change"
fi



echo ================= 4.1.12 ======== 

VARIABLE="grep mounts /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts " >> /etc/audit/rules.d/mounts.rules
        echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/rules.d/mounts.rules
        echo "OK change"
fi


echo ================= 4.1.13 ======== 

VARIABLE="find /tmp -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print \"-a always,exit -F path=\" $1 \" -F perm=x -F auid>='\"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)\"' -F auid!=4294967295 -k privileged\" }'"
VARIABLE=$(eval "$VARIABLE")



echo ================= 4.1.14 ======== 

VARIABLE="grep delete /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete " >> /etc/audit/rules.d/delete.rules
        echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/rules.d/delete.rules
        echo "OK change"
fi


echo ================= 4.1.15 ======== 

VARIABLE="grep modules /etc/audit/rules.d/*.rules"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        echo "OK"
else
        echo "-w /sbin/insmod -p x -k modules " >> /etc/audit/rules.d/modules.rules
        echo "-w /sbin/rmmod -p x -k modules " >> /etc/audit/rules.d/modules.rules
        echo "-w /sbin/modprobe -p x -k modules " >> /etc/audit/rules.d/modules.rules
        echo "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" >> /etc/audit/rules.d/modules.rules
        echo "OK change"
fi



echo ================= 4.1.16 ======== 
echo "-w /var/log/sudo.log -p wa -k actions" >> /etc/audit/rules.d/audit.rules
echo "OK"



echo ================= 4.1.17 ======== 

VARIABLE="grep \"^\s*[^#]\" /etc/audit/rules.d/*.rules | tail -1"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "-e 2" ]]; then
        echo "OK"
else
        echo "-e 2" >> /etc/audit/rules.d/99-finalize.rules
        echo "OK change"
fi


echo ================= 4.2.1.1 ================= 

VARIABLE="dpkg -s rsyslog"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        apt -y install rsyslog
        echo "OK"
else
        echo "OK install"
fi


echo ================= 4.2.1.2 ======== 
VARIABLE="systemctl is-enabled rsyslog"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "enabled" ]]; then
        systemctl --now enable rsyslog
        echo "OK"
else
        echo "OK install"
fi


echo ================= 4.2.1.3 ======== 


VARIABLE="grep ^\$FileCreateMode /etc/rsyslog.conf /etc/rsyslog.d/*.conf"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "0640" ]]; then
                sed -i 's/$FileCreateMode/#$FileCreateMode"/g' /etc/rsyslog.conf
                echo "\$FileCreateMode 0640" >> /etc/rsyslog.conf
                echo "OK change"
        else
                echo "\$FileCreateMode 0640" >> /etc/rsyslog.conf
                echo "OK"
        fi
else
        echo "\$FileCreateMode 0640" >> /etc/rsyslog.conf
        echo "OK"
fi


echo ================= 4.2.1.4 ======== 


echo '*.emerg :omusrmsg:* ' >> /etc/rsyslog.conf
echo 'auth,authpriv.* /var/log/secure' >> /etc/rsyslog.conf
echo 'mail.* -/var/log/mail  ' >> /etc/rsyslog.conf
echo 'mail.info -/var/log/mail.info  ' >> /etc/rsyslog.conf
echo 'mail.warning -/var/log/mail.warn  ' >> /etc/rsyslog.conf
echo 'mail.err /var/log/mail.err  ' >> /etc/rsyslog.conf
echo 'news.crit -/var/log/news/news.crit  ' >> /etc/rsyslog.conf
echo 'news.err -/var/log/news/news.err  ' >> /etc/rsyslog.conf
echo 'news.notice -/var/log/news/news.notice  ' >> /etc/rsyslog.conf
echo '*.=warning;*.=err -/var/log/warn  ' >> /etc/rsyslog.conf
echo '*.crit /var/log/warn  ' >> /etc/rsyslog.conf
echo '*.*;mail.none;news.none -/var/log/messages  ' >> /etc/rsyslog.conf
echo 'local0,local1.* -/var/log/localmessages '>> /etc/rsyslog.conf
echo 'local2,local3.* -/var/log/localmessages '>> /etc/rsyslog.conf
echo 'local4,local5.* -/var/log/localmessages  ' >> /etc/rsyslog.conf
echo 'local6,local7.* -/var/log/localmessages ' >> /etc/rsyslog.conf

systemctl restart rsyslog
echo "OK"


echo ================= 4.2.1.6 ======== 

VARIABLE="grep '$ModLoad' /etc/rsyslog.conf /etc/rsyslog.d/*.conf"
VARIABLE=$(eval "$VARIABLE")

VARIABLE1="grep '$InputTCPServerRun' /etc/rsyslog.conf /etc/rsyslog.d/*.conf"
VARIABLE1=$(eval "$VARIABLE")

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "$ModLoad imtcp" ]]; then
                sed -i 's/$ModLoad/#$ModLoad"/g' /etc/rsyslog.conf
                echo "\$ModLoad imtcp" >> /etc/rsyslog.conf
                echo "OK change"
        else
                echo "\$ModLoad imtcp" >> /etc/rsyslog.conf
                echo "OK"
        fi
else 
        echo "\$ModLoad imtcp" >> /etc/rsyslog.conf
        echo "OK"
fi

if [[ $VARIABLE1 != "" ]]; then
        if [[ $VARIABLE1 != "$InputTCPServerRun 514" ]]; then
                sed -i 's/$InputTCPServerRun/#$InputTCPServerRun"/g' /etc/rsyslog.conf
                echo "\$InputTCPServerRun 514" >> /etc/rsyslog.conf
                echo "OK change"
        else
                echo "\$InputTCPServerRun 514" >> /etc/rsyslog.conf
                echo "OK"
        fi
else 
        echo "\$InputTCPServerRun 514" >> /etc/rsyslog.conf
        echo "OK"
fi


echo ================= 4.2.2.1 ======== 

VARIABLE="grep -e ^\s*ForwardToSyslog /etc/systemd/journald.conf"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "ForwardToSyslog=yes" ]]; then
                sed -i 's/ForwardToSyslog/#ForwardToSyslog"/g' /etc/systemd/journald.conf
                echo "ForwardToSyslog=yes" >> /etc/systemd/journald.conf
                echo "OK change"
        else
                echo "ForwardToSyslog=yes" >> /etc/systemd/journald.conf
                echo "OK"
        fi
else 
        echo "ForwardToSyslog=yes" >> /etc/systemd/journald.conf
        echo "OK"
fi


echo ================= 4.2.2.2 ======== 

VARIABLE="grep -e ^\s*Compress /etc/systemd/journald.conf"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "Compress=yes" ]]; then
                sed -i 's/Compress*/#Compress"/g' /etc/systemd/journald.conf
                echo "OK change"
        else
                echo "Compress=yes" >> /etc/systemd/journald.conf
                echo "OK"
        fi
else 
        echo "Compress=yes" >> /etc/systemd/journald.conf
        echo "OK"
fi


echo ================= 4.2.2.3 ======== 

VARIABLE="grep -e ^\s*Storage /etc/systemd/journald.conf"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "Storage=persistent" ]]; then
                sed -i 's/Storage/#Storage"/g' /etc/systemd/journald.conf
                echo "Storage=persistent" >> /etc/systemd/journald.conf
                echo "OK change"
        else
                echo "Storage=persistent" >> /etc/systemd/journald.conf
                echo "OK"
        fi
else 
        echo "Storage=persistent" >> /etc/systemd/journald.conf
        echo "OK"
fi


# echo ================= 4.2.3 ======== 

# VARIABLE="find /var/log -type f -perm /037 -ls -o -type d -perm /026 -ls"
# VARIABLE=$(eval "$VARIABLE")


# if [[ $VARIABLE != "" ]]; then
#         find /var/log -type f -exec chmod 755 "{}" + -o -type d -exec chmod 755 "{}" +
#         echo "OK change"
# else
#         echo "OK"
# fi


echo ================= 5.1.1 ======== 

VARIABLE="systemctl is-enabled crond"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "enabled" ]]; then
        systemctl --now enable crond
        echo "OK change"
else
        echo "OK"
fi


echo ================= 5.1.2 ======== 
chown root:root /etc/crontab
chmod og-rwx /etc/crontab
echo "OK"


echo ================= 5.1.3 ======== 
chown root:root /etc/cron.hourly
chmod og-rwx /etc/cron.hourly
echo "OK"


echo ================= 5.1.4 ======== 
chown root:root /etc/cron.daily
chmod og-rwx /etc/cron.daily
echo "OK"


echo ================= 5.1.5 ======== 
chown root:root /etc/cron.weekly
chmod og-rwx /etc/cron.weekly
echo "OK"


echo ================= 5.1.6 ======== 
chown root:root /etc/cron.monthly
chmod og-rwx /etc/cron.monthly
echo "OK"


echo ================= 5.1.7 ======== 
chown root:root /etc/cron.d
chmod og-rwx /etc/cron.d
echo "OK"


echo ================= 5.1.8 ======== 

VARIABLE="stat /etc/cron.deny"
VARIABLE=$(eval "$VARIABLE")

VARIABLE1="stat /etc/at.deny"
VARIABLE1=$(eval "$VARIABL1")

if [[ $VARIABLE =~ "No such file" ]] || [[ $VARIABLE1 =~ "No such file" ]]; then
        echo "OK"
else
        rm /etc/cron.deny # 
        rm /etc/at.deny # 
        touch /etc/cron.allow # 
        touch /etc/at.allow # 
        chmod og-rwx /etc/cron.allow # 
        chmod og-rwx /etc/at.allow # 
        chown root:root /etc/cron.allow # 
        chown root:root /etc/at.allow
        echo "OK change"
fi


# echo ================= 5.2.1 ======== 
# chown root:root /etc/ssh/sshd_config # 
# chmod og-rwx /etc/ssh/sshd_config
# echo "OK"


# echo ================= 5.2.20 ======== 
# sed -ri "s/^\s*(CRYPTO_POLICY\s*=.*)$/# \1/" /etc/sysconfig/sshd # 


# echo ================= 5.2.3 ======== 

# find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \; # 
# find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 0600 {} \;


# echo ================= 5.2.4 ======== 

# find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 0644 {} \; #
# find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;


# echo ================= 5.2.20 ======== 
# sed -ri "s/^\s*(CRYPTO_POLICY\s*=.*)$/# \1/" /etc/sysconfig/sshd # 
# systemctl reload sshd


echo ================= 5.5.1.1 ========  

VARIABLE=$(grep PASS_MAX_DAYS /etc/login.defs)

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "PASS_MAX_DAYS 365" ]]; then
                sed -i 's/PASS_MAX_DAYS/#PASS_MAX_DAYS/' /etc/login.defs
                echo "PASS_MAX_DAYS 365" >> /etc/login.defs
                echo "OK change"
        else
                echo "PASS_MAX_DAYS 365" >> /etc/login.defs
                echo "OK"
        fi
else 
        echo "PASS_MAX_DAYS 365" >> /etc/login.defs
        echo "OK"
fi


echo ================= 5.5.1.2 ========  

VARIABLE=$(grep PASS_MIN_DAYS /etc/login.defs)

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "PASS_MIN_DAYS 7" ]]; then
                sed -i 's/PASS_MIN_DAYS/#PASS_MIN_DAYS/' /etc/login.defs
                echo "PASS_MIN_DAYS 30" >> /etc/login.defs
                echo "OK change"
        else
                echo "PASS_MIN_DAYS 30" >> /etc/login.defs
                echo "OK"
        fi
else 
        echo "PASS_MIN_DAYS 30" >> /etc/login.defs
        echo "OK"
fi



echo ================= 5.5.1.3 ========  #MODIFICARLO /etc/login.defs

VARIABLE=$(grep PASS_WARN_AGE /etc/login.defs)

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "PASS_WARN_AGE 7" ]]; then
                sed -i 's/PASS_WARN_AGE/#PASS_WARN_AGE/' /etc/login.defs
                echo "PASS_WARN_AGE 7" >> /etc/login.defs
                echo "OK change"
        else
                echo "PASS_WARN_AGE 7" >> /etc/login.defs
                echo "OK"
        fi
else 
        echo "PASS_WARN_AGE 7" >> /etc/login.defs
        echo "OK"
fi


echo ================= 5.5.3 ======== 

VARIABLE="grep "^TMOUT" /etc/bashrc"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "readonly TMOUT=900 ; export TMOUT" ]]; then
                sed -i 's/TMOUT=900*/TMOUT=900"/g' /etc/bashrc
                echo "OK change"
        else
                echo "readonly TMOUT=900 ; export TMOUT" >> /etc/bashrc
                echo "OK"
        fi
else 
        echo "readonly TMOUT=900 ; export TMOUT" >> /etc/bashrc
        echo "OK"
fi

VARIABLE="grep "^TMOUT" /etc/profile"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        if [[ $VARIABLE != "readonly TMOUT=900 ; export TMOUT" ]]; then
                sed -i 's/TMOUT=900*/TMOUT=900"/g' /etc/bashrc
                echo "OK change"
        else
                echo "readonly TMOUT=900 ; export TMOUT" >> /etc/profile
                echo "OK"
        fi
else 
        echo "readonly TMOUT=900 ; export TMOUT" >> /etc/profile
        echo "OK"
fi

VARIABLE="grep "^TMOUT" /etc/profile.d/*.sh"
VARIABLE=$(eval "$VARIABLE")
if [[ $VARIABLE != "" ]]; then
        for n in ${VARIABLE}
        do
                VARIABLE1=$(grep "^TMOUT" $n)
                if [[ $VARIABLE1 != "" ]]; then
                        if [[ $VARIABLE1 != "readonly TMOUT=900 ; export TMOUT" ]]; then
                                sed -i 's/TMOUT*/TMOUT=900 ; export TMOUT"/g' $n
                                echo "OK change"
                        else
                                echo "readonly TMOUT=900 ; export TMOUT" >> $n
                                echo "OK"
                        fi
                else 
                        echo "readonly TMOUT=900 ; export TMOUT" >> $n
                        echo "OK"
                fi
        done
else
        echo "OK"
fi



echo ================= 5.6 ======== 

VARIABLE="cat /etc/securetty"
VARIABLE=$(eval "$VARIABLE")


if [[ $VARIABLE != "" ]]; then
        rm /etc/securetty
        echo "OK change"
else
        echo "OK"
fi



echo ================= 6.1.1 ======== 

dpkg --verify bash

# echo ================= 6.1.4 ======== 

# VARIABLE="stat /etc/group"
# VARIABLE=$(eval "$VARIABLE")


# if [[ $VARIABLE =~ "0644" ]]; then
#         echo "OK"
# else
#         chown root:root /etc/group # 
#         chmod 644 /etc/group
#         echo "OK change"
        
# fi



# echo ================= 6.1.8 ======== 

# VARIABLE="stat /etc/group-"
# VARIABLE=$(eval "$VARIABLE")


# if [[ $VARIABLE =~ "0644" ]]; then
#         echo "OK"
# else
#         chown root:root /etc/group- # 
#         chmod u-x,go-wx /etc/group-
#         echo "OK change"
        
# fi


# echo ================= 6.1.9 ======== 

# VARIABLE="stat /etc/gshadow-"
# VARIABLE=$(eval "$VARIABLE")


# if [[ $VARIABLE =~ "0640" ]]; then
#         echo "OK"
# else
#         chown root:root /etc/gshadow- # 
#         chown root:shadow /etc/gshadow- # 
#         chmod o-rwx,g-rw /etc/gshadow-
#         echo "OK change"
        
# fi


# echo ================= 6.1.10 ========  
# VARIABLE=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -0002)


# if [[ $VARIABLE != "" ]]; then
#         for n in ${VARIABLE}
#         do
#                 echo $n
#                 VARIABLE1=$(find $n -xdev -type f -perm -0002 2>~/bitacora_Endurecimiento_SO.log)
#                 chmod o-w $VARIABLE1 2>~/bitacora_Endurecimiento_SO.log
#         done
#         echo "OK change"
# else
#         echo "OK"
# fi



# echo ================= 6.1.12 ========  

# VARIABLE=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -nogroup)

# if [[ $VARIABLE != "" ]]; then
#         for n in ${VARIABLE}
#         do
#                 VARIABLE1=$(find $n -xdev -nogroup 2>~/bitacora_Endurecimiento_SO.log)
#                 chmod o-w $VARIABLE1 2>~/bitacora_Endurecimiento_SO.log
#         done
#         echo "OK change"
# else
#         echo "OK"
# fi


# echo ================= 6.1.13 ========  

# VARIABLE=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -4000)

# if [[ $VARIABLE != "" ]]; then
#         for n in ${VARIABLE}
#         do
#                 VARIABLE1=$(find $n -xdev -type f -perm -4000 2>~/bitacora_Endurecimiento_SO.log)
#                 chmod o-w $VARIABLE1 2>~/bitacora_Endurecimiento_SO.log
#         done
#         echo "OK change"
# else
#         echo "OK"
# fi


# echo ================= 6.1.14 ========  

# VARIABLE=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -2000)

# if [[ $VARIABLE != "" ]]; then
#         for n in ${VARIABLE}
#         do
#                 VARIABLE1=$(find $n -xdev -type f -perm -2000 2>~/bitacora_Endurecimiento_SO.log)
#                 chmod o-w $VARIABLE1 2>~/bitacora_Endurecimiento_SO.log
#         done
#         echo "OK change"
# else
#         echo "OK"
# fi




# echo ================= 6.2.3 ======== 

# for x in $(echo $PATH | tr ":" " ") ; 
# do 
#         if [ -d "$x" ] ; then 
#                 ls -ldH "$x" | awk ' $9 == "." {print "PATH contains current working directory (.)"} $3 != "root" {print $9, "is not owned by root"} substr($1,6,1) != "-" {print $9, "is group writable"} substr($1,9,1) != "-" {print $9, "is world writable"}' 
#         else 
#                 echo "$x is not a directory"
#         fi 
# done



echo ================= 6.2.16 ======== 

cut -d: -f3 /etc/group | sort | uniq -d | while read x ; do 
        echo "Duplicate GID ($x) in /etc/group" 
done
echo "OK"




echo ================= 2.1.4 ================= 

VARIABLE="dpkg -s cups"
VARIABLE=$(eval "$VARIABLE")

if [[ $VARIABLE =~ "not installed" ]]; then
        echo "OK disabled"
else
apt purge cups -y
echo "OK disabled now"
fi


echo ================= aide ======== 
echo "END"


apt install aide aide-common -y

echo "/bin/\..*  PERMS" >> /etc/aide.conf
echo "/bin/   CONTENT_EX" >> /etc/aide.conf
echo "/bin/   DATAONLY" >> /etc/aide.conf
echo "/sbin/\..*  PERMS" >> /etc/aide.conf
echo "/sbin/   CONTENT_EX" >> /etc/aide.conf
echo "/sbin/   DATAONLY" >> /etc/aide.conf
echo "/lib/\..*  PERMS" >> /etc/aide.conf
echo "/lib/   CONTENT_EX" >> /etc/aide.conf
echo "/lib/   DATAONLY" >> /etc/aide.conf
echo "/usr/\..*  PERMS" >> /etc/aide.conf
echo "/usr/   CONTENT_EX" >> /etc/aide.conf
echo "/usr/   DATAONLY" >> /etc/aide.conf
echo "/etc/\..*  PERMS" >> /etc/aide.conf
echo "/etc/   CONTENT_EX" >> /etc/aide.conf
echo "/etc/   DATAONLY" >> /etc/aide.conf
echo "/var/www/\..*  PERMS" >> /etc/aide.conf
echo "/var/www/   CONTENT_EX" >> /etc/aide.conf
echo "/var/www/   DATAONLY" >> /etc/aide.conf

aideinit
mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

cat > /etc/systemd/system/aidecheck.service << "EOF"
[Unit]
Description=Aide Check
#
[Service]
Type=simple
ExecStart=/usr/bin/aide.wrapper --check

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/aidecheck.timer << "EOF"
[Unit]
Description=Aide check every day at midnight

[Timer]
OnCalendar=*-*-* 00:00:00
Unit=aidecheck.service

[Install]
WantedBy=multi-user.target
EOF

chown root:root /etc/systemd/system/aidecheck.*
chmod 0644 /etc/systemd/system/aidecheck.*
systemctl daemon-reload

systemctl enable aidecheck.service
systemctl --now enable aidecheck.timer

echo ================= CLAM ======== 

apt install clamav clamav-daemon -y

systemctl stop clamav-freshclam
freshclam
systemctl start clamav-freshclam
