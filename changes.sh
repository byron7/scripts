#! /bin/bash
LOGIN=$(lastlog | grep $USER | awk '{print $2}')

if [[ $LOGIN =~ "Never" ]]; then
	read -p "Desea cambiar el hostname y la IP del servidor ahora [s/n]: " RESPUESTA

	if [[ $RESPUESTA = "s" ]]; then
		read -p "Ingrese el hostname al que se quiere cambiar: " NEW_HOSTNAME
		read -p "Escriba la IP que desea asignarle como por ejemplo 192.168.1.1: " IP_ADDRESS
		read -p "La ip del gateway: " GATEWAY_ADDRESS
		read -p "La IP del DNS: " PRIMARY_DNS_ADDRESS

		sudo hostnamectl set-hostname "$NEW_HOSTNAME"

		sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.$(date +%Y%m%d%T)

		sudo cat > 00-installer-config.yaml << "EOF"
		network:
		  ethernets:
		    ens33:
		      dhcp4: false
		      addresses:"
		       - [$IP_ADDRESS]
		      routes:"
		       - to: default"
		         via: $GATEWAY_ADDRESS
		      nameservers:
		        addresses: [$PRIMARY_DNS_ADDRESS]
		  version: 2
EOF
		sudo mv 00-installer-config.yaml /etc/netplan/00-installer-config.yaml
		sudo netplan apply
	fi
fi
