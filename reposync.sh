#!/bin/bash
#
# Script pour récupérer les derniers paquets des repos 7.6, 8.9 et 8.10
#
# Doc: https://access.redhat.com/solutions/7019225

# Echo des commandes du script
# set -x

LOGDIR=/Repository/Logs
options="--newest-only"

echo "-- Script de récupération des paquets pour Rhel 8.9, 8.10 et Centos 7.6"
echo "Attention: Centos 7.6 est EOL, il n'y a pas de nouveaux paquets mis à jour."

echo "Définition des options de récupération des repos:"
read -p "Par defaut, l'option --newest-only est appliquée. Voulez-vous télécharger toutes les versions disponnibles ? (Y/n) " choix_option
if [ $choix_option = "Y" ]; then options=""; fi

# Loop pour les OS Rhel 8.9, Rhel 8.10 et Centos7.6
for OS in RHEL8 Centos7
do
    if [ $OS = RHEL8 ] # pour les RHEL
    then
        for OS_version in 8.9 8.10
        do
            echo $OS $OS_version
            # Creation du fichier de log pour chaque version
            LOGFILE=$LOGDIR/$OS_version/reposync-$OS_version-$(date +%F).log

            # Modification de la release choisie dans subscription-manager (8.9 ou 8.10) et clean du cache dnf pour nettoyer les metadonnées
            subscription-manager release --set=$OS_version && rm -rf /var/cache/dnf &>> $LOGFILE

            # Récupération des repos baseos et appstream
            for repo in baseos appstream; do echo Reposync pour $OS $OS_version - $repo ; reposync -p /Repository/$OS/$OS_version --download-metadata --repoid=rhel-8-for-x86_64-$repo-rpms $options &>> $LOGFILE && echo "Reposync réussi" || echo "Quelque chose s'est mal passé, consultez $LOGFILE pour plus d'informations" ; done
        done

    else # pour les Centos 7.6
        echo Centos 7.6
        
        # Modification de la valeur de LogFile pour l'OS 7.6
        LOGFILE=$LOGDIR/7.6/reposync-7.6-$(date +%F).log
        
        # Récupération des repos base, extras et updates
        for repo in base extras updates
        do 
            echo Reposync pour Centos7 7.6 - $repo
            reposync -p /Repository/Centos7/7.6/ --repoid=$repo --download-metadata $options &>> $LOGFILE && echo "Reposync réussi" || echo "Quelque chose s'est mal passé, consultez $LOGFILE pour plus d'informations"
            createrepo /Repository/Centos7/7.6/$repo
        done
    fi
done

echo "-- Fin d'éxecution du script"