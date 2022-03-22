#!/bin/bash

#function Update Civicrm Drupal
updateCivicrmDrupal(){

    cd $civi_folder/httpdocs

    civi_name=$( cv ev 'return CRM_Utils_System::version();' );

    cd sites/all/modules/

    if [[ `wget -S --spider https://download.civicrm.org/civicrm-$civi_version-drupal.tar.gz  2>&1 | grep 'HTTP/1.1 200 OK'` ]]
    then
       #echo $civi_language

        wget https://download.civicrm.org/civicrm-$civi_version-drupal.tar.gz

        # DL l10n
        wget https://download.civicrm.org/civicrm-$civi_version-l10n.tar.gz

        # clear cache civi
        cv flush

        # setup backup folder
        [[ ! -d "civicrm-backup-tmp" ]] && mkdir -p civicrm-backup-tmp
        [[ ! -d "civicrm-backup-tmp/$civi_name" ]] && mkdir -p civicrm-backup-tmp/$civi_name
        [[ ! -d "mkdir -p langueMysql" ]] && mkdir -p mkdir -p langueMysql

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
            if [[ "$l10nFile" = "civicrm/l10n/$civi_language" ]]
            then
                echo ""
            else
                rm -rf $l10nFile
            fi
        done

        cp -R civicrm/sql/* langueMysql/
        for sqlFile in langueMysql/*; do
            if [[ "$sqlFile" = "langueMysql/civicrm_data.$civi_language.mysql" ||
                "$sqlFile" = "langueMysql/civicrm_acl.$civi_language.mysql" ||
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
                echo ""
            else
                rm -rf $sqlFile
            fi
        done

        rm -rf civicrm/sql/*
        cp -R langueMysql/* civicrm/sql/

        cv api Setting.create lcMessages="$civi_language"

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

        # plesk repair all -y

        echo -e '\e[93m=============================================\033[0m'
        echo -e '\e[93m' $civi_name '\e[92m -> \033[32m UPGRADE END !\033[0m'
        echo -e '\e[93m=============================================\033[0m'
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e '\e[93m\033[31m Aucune version de Civicrm trouvé\033[31m'
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi
}


#function Update Civicrm Wordpress
updateCivicrmWordpress(){

    cd $civi_folder/httpdocs

    civi_name=$( cv ev 'return CRM_Utils_System::version();' );

    cd wp-content/plugins/

    if [[ `wget -S --spider https://download.civicrm.org/civicrm-$civi_version-wordpress.zip  2>&1 | grep 'HTTP/1.1 200 OK'` ]]
    then
       #echo $civi_language

        wget https://download.civicrm.org/civicrm-$civi_version-wordpress.zip

        # DL l10n
        wget https://download.civicrm.org/civicrm-$civi_version-l10n.tar.gz

        # clear cache civi
        cv flush

        # setup backup folder
        [[ ! -d "civicrm-backup-tmp" ]] && mkdir -p civicrm-backup-tmp
        [[ ! -d "civicrm-backup-tmp/$civi_name" ]] && mkdir -p civicrm-backup-tmp/$civi_name
        [[ ! -d "langueMysql" ]] && mkdir -p langueMysql

        cd civicrm-backup-tmp/$civi_name

        cd ../..

        # move actual plugin to the tmp folder
        A | mv civicrm civicrm-backup-tmp/$civi_name

        # unzip the new version
        unzip civicrm-$civi_version-wordpress.zip

        # unzip the new l10n
        tar -xzf civicrm-$civi_version-l10n.tar.gz

        #copy l10n content to the civicrm folder
        cp -R civicrm/l10n civicrm/civicrm/l10n
        for l10nFile in civicrm/l10n/*; do
            if [[ "$l10nFile" = "civicrm/l10n/$civi_language" ]]
            then
                echo ""
            else
                rm -rf $l10nFile
            fi
        done

        cp -R civicrm/sql/* langueMysql/
        for sqlFile in langueMysql/*; do
            if [[ "$sqlFile" = "langueMysql/civicrm_data.$civi_language.mysql" ||
                "$sqlFile" = "langueMysql/civicrm_acl.$civi_language.mysql" ||
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
        cp -R langueMysql/* civicrm/civicrm/sql/

        cv api Setting.create lcMessages="$civi_language"

        rm -rf langueMysql/
        rm -rf civicrm-$civi_version-wordpress.zip
        rm -rf civicrm-$civi_version-l10n.tar.gz

        # upgrade db
        cv upgrade:db

        # upgrade bundled extension
        cv ext:upgrade-db

        # clear civi cache
        cv flush

        #plesk repair all -y

        echo -e '\e[93m=============================================\033[0m'
        echo -e '\e[93m' $civi_name '\e[92m -> \033[32m UPGRADE END !\033[0m'
        echo -e '\e[93m=============================================\033[0m'
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e '\e[93m\033[31m Aucune version de Civicrm trouvé\033[31m'
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi
}