#! /bin/bash
LOGIN=$(lastlog | grep $USER | awk '{print $2}')

if [[ $LOGIN =~ "Never" ]]; then
	read -p "Desea cambiar el hostname y la IP del servidor ahora [s/n]: " RESPUESTA

	if [[ $RESPUESTA = "s" ]]; then
		read -p "Ingrese el hostname al que se quiere cambiar: " NEW_HOSTNAME
		read -p "Escriba la IP que desea asignarle con el siguiente formato por ejemplo 192.168.1.1/24: " IP_ADDRESS

		sudo hostnamectl set-hostname "$NEW_HOSTNAME"
  		sudo ifconfig ens33 $IP_ADDRESS
	fi
fi
