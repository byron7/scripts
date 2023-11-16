#! /usr/bin/env bash
LOGIN = lastlog | grep $USER | awk '{print $2}'

if [ $LOGIN =~ "Never" ]; then
	read -p "Desea cambiar el hostname y la IP del servidor [s/n] ahora: " RESPUESTA

	if [ $RESPUESTA = "n" ]; then
		read -p "Ingrese el hostname al que se quiere cambiar: " NEW_HOSTNAME
		read -p "Escriba la IP que desea asignarle como por ejemplo 192.168.1.1/24: " IP_ADDRESS
		read -p "La ip del gateway: " GATEWAY_ADDRESS
		read -p "La IP del DNS: " PRIMARY_DNS_ADDRESS

		sudo hostnamectl set-hostname "$NEW_HOSTNAME"

		mv /etc/netplan/99-custom.yaml /etc/netplan/99-custom.yaml.$(date +%Y%m%d)

		cat > /etc/netplan/99-custom.yaml << "EOF"
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

		sudo netplan apply
	fi
fi
