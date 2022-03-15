#!/bin/bash

################################################
##
##  Update CIVI plugin in Drupal
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
    #echo $civi_name

    cd ../..

    ######################################################
    ## UPDATE
    ######################################################

    # get the folder
    cd $civi_folder/httpdocs/sites/all/modules/

    if [[ `wget -S --spider https://download.civicrm.org/civicrm-$civi_version-drupal.tar.gz  2>&1 | grep 'HTTP/1.1 200 OK'` ]] 
    then 
        wget https://download.civicrm.org/civicrm-$civi_version-drupal.tar.gz

        # DL l10n
        wget https://download.civicrm.org/civicrm-$civi_version-l10n.tar.gz

        # clear cache civi
        cv flush

        # put the site into maintenance mode
        #drush vset maintenance_mode 1

        # setup backup folder
        mkdir -p civicrm-backup-tmp/$civi_name
        mkdir -p langueMysql

        cd civicrm-backup-tmp/$civi_name

        # save db
        drush sql-dump

        cd ../..

        # move actual plugin to the tmp folder
        yes | mv civicrm civicrm-backup-tmp/$civi_name

        # unzip the new version
        tar -xzf civicrm-$civi_version-drupal.tar.gz

        # unzip the new l10n
        tar -xzf civicrm-$civi_version-l10n.tar.gz

        #copy l10n content to the civicrm folder
        cp -R civicrm/l10n civicrm/l10n
        for l10nFile in civicrm/l10n/*; do
            #echo "put $l10nFile"
            if [[ "$l10nFile" = "civicrm/l10n/fr_FR" ]]
            then
                echo " "
            else 
                rm -rf $l10nFile
            fi
        done

        cp -R civicrm/sql/* langueMysql/
        for sqlFile in langueMysql/*; do
            #echo "put $sqlFile"
            if [[ "$sqlFile" = "langueMysql/civicrm_data.fr_FR.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_acl.fr_FR.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_sample_custom_data.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_sample.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_queue_item.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_navigation.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_generated_report.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_generated.mysql" ||
                "$sqlFile" = "langueMysql/civicrm_dummy_processor.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_drop.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_devel_config.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_demo_processor.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_data.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_case_sql.mysql" || 
                "$sqlFile" = "langueMysql/civicrm_acl.mysql" || 
                "$sqlFile" = "langueMysql/civicrm.mysql" ||
                "$sqlFile" = "langueMysql/case_sample.mysql" ]]
            then
                echo " "
            else 
                rm -rf $sqlFile
            fi
        done

        rm -rf civicrm/sql/*
        cp -R langueMysql/* civicrm/sql/

        cv api Setting.create lcMessages="fr_FR"

        rm -rf langueMysql/
        rm -rf civicrm-$civi_version-drupal.tar.gz
        rm -rf civicrm-$civi_version-l10n.tar.gz

        # upgrade db
        cv upgrade:db

        # upgrade bundled extension
        cv ext:upgrade-db

        # clear civi cache
        cv flush

        # check plugin status
        drush pm-updatestatus civicrm

        # clear drupal cache
        drush cache-clear all

        echo -e '\e[93m=============================================\033[0m'
        echo -e '\e[93m' $civi_name '\e[92m -> \033[32m UPGRADE END !\033[0m'
        echo -e '\e[93m=============================================\033[0m'
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