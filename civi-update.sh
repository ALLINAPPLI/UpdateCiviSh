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

#add functions file
source functions.sh
source ~/.bashrc


echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance que vous souhaitez mettre à jour ?"
echo "Liste des domaines disponibles : "
echo " "
listSite=$(plesk bin site --list);
echo ${listSite[@]}
echo " "
read civi_folder
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez la langue dans laquel doit etre civicrm ?"
echo " "
listLanguage=(
"af_ZA" "da_DK" "en_CA" "fa_IR" "hi_IN" "ja_JP" "mk_MK" "pt_BR" "sl_SI" "uk_UA"
"r_EG" "de_CH" "en_GB" "fi_FI" "hu_HU" "km_KH" "nb_NO" "pt_PT" "sq_AL" "vi_VN"
"g_BG" "de_DE" "es_ES" "fr_CA" "hy_AM" "ko_KR" "nl_BE" "ro_RO" "sr_RS" "zh_CN"
"a_ES" "el_GR" "es_MX" "fr_FR" "id_ID" "lt_LT" "nl_NL" "ru_RU" "sv_SE" "zh_TW"
"s_CZ" "en_AU" "et_EE" "he_IL" "it_IT" "lv_LV" "pl_PL" "sk_SK" "tr_TR")
echo ""
echo ${listLanguage[@]}
read civi_language
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez la version que vous souhaitez installer (X.YY.Z)  ?"
echo ""
CiviVersion=("5.44" "5.45" "5.46" "5.47")
echo ${CiviVersion[@]}
read civi_version
echo -e '\e[93m=============================================\033[0m'

echo -e '\e[93m=============================================\033[0m'
echo "Wordpress ou Drupal ?"
echo " "
read civicrm_version
echo -e '\e[93m=============================================\033[0m'


if [[ $civi_version =~ ^[0-9]*.[0-9]*.[0-9]*$ ]]
then
    if [[ "$civicrm_version" = "Wordpress" ]]
    then
        #echo "Wordpress"
        #functions updateCivicrmWordpress
        updateCivicrmWordpress civi_folder civi_version civi_language
    elif [[ "$civicrm_version" = "Drupal" ]]
    then
        #echo "Drupal"
        #functions updateCivicrmDrupal 
        updateCivicrmDrupal civi_folder civi_version civi_language 
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e '\e[93m\033[31m Aucun CMS valide sélectionné \033[31m'
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi
else
    echo -e '\e[93m=======================================\033[0m'
    echo -e '\e[93m\033[31m Ce n est pas un nombre\033[31m'
    echo -e '\e[93m=======================================\033[0m'
    exit 1
fi