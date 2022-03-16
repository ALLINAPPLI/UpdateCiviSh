#!/bin/bash
##
## Développer par Renaud Fradin est Fawzy Elsam
##
################################################
##
##  Update CIVI plugin in Drupal on plesk
##
################################################

shopt -s expand_aliases

######################################################
## security check
######################################################

if [ ! -f ~/.bashrc ]; then
    printf -- '\033[41m  .bashrc must exist. abord. \033[0m\n'
    exit 1
fi

source functions.sh

source ~/.bashrc
echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance que vous souhaitez mettre à jour ?"
echo "Liste des domaines disponibles : "
echo " "
plesk bin site --list
echo " "
read civi_folder
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez la version que vous souhaitez installer (X.YY.Z)  ?"
echo ""
arrayCiviVersion=("5.41" "5.42" "5.43" "5.44" "5.45" "5.46" "5.47")
echo ${arrayCiviVersion[@]}
read civi_version


if [[ $civi_version =~ ^[0-9]*.[0-9]*.[0-9]*$ ]]
then
    cd $civi_folder/httpdocs

    civi_name=$( cv ev 'return CRM_Utils_System::version();' );

    cd sites/all/modules/

    if [[ `wget -S --spider https://download.civicrm.org/civicrm-$civi_version-drupal.tar.gz  2>&1 | grep 'HTTP/1.1 200 OK'` ]]
    then
        #functions updateCivirm
        updateCivicrm
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e '\e[93m\033[31m Aucune version de Civicrm trouvé\033[31m'
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi
else
    echo -e '\e[93m=======================================\033[0m'
    echo -e '\e[93m\033[31m Ce nest pas un nombre\033[31m'
    echo -e '\e[93m=======================================\033[0m'
    exit 1
fi