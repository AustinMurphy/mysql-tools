#!/bin/bash

#
#  The goal is to only delete old backups if necessary
#  


UTILDIR=/home/mysql/util

# Source common options
. $UTILDIR/bk-common.sh


# BACKUPDIRBASE=/data/backup
# 
# # TODO: test if it exists
# 
# 
# # normal backups are marked with "crondaily" in the backup filename
# 
# # TODO:  establish crondaily, cronweekly, & cronmonthly backups
# 


echo "----------------------------------------"
echo ""
echo "      MySQL backups cleanup report    "
echo ""
echo "----------------------------------------"


display_header


display_disk_usage


display_age_settings


display_counts


delete_old_backups

# not sure if this is working right
delete_empty_dirs


display_disk_usage


echo ""
echo ""
#echo "----------------------------------------"




#delete_old_backups() {
#
#    #
#    #  delete the old ones
#    #
#    
#    echo "Deleting $SINGLESOLD Single backups more than $SINGLESMAXAGE days old ... "
#    sleep 2
#    find ${BACKUPDIRBASE}/ -regex '.*single.*' -mtime +${SINGLESMAXAGE} -exec rm {} \;
#    
#    echo "Deleting $MONTHLYSOLD Monthly backups more than $MONTHLYMAXAGE days old ... "
#    sleep 2
#    find ${BACKUPDIRBASE}/ -regex '.*cronmonthly.*' -mtime +${MONTHLYMAXAGE} -exec rm {} \;
#    
#    echo "Deleting $WEEKLYSOLD Weekly backups more than $WEEKLYMAXAGE days old ... "
#    sleep 2
#    find ${BACKUPDIRBASE}/ -regex '.*cronweekly.*' -mtime +${WEEKLYMAXAGE} -exec rm {} \;
#    
#    echo "Deleting $DAILYSOLD Daily backups more than $DAILYMAXAGE days old ... "
#    sleep 2
#    find ${BACKUPDIRBASE}/ -regex '.*crondaily.*' -mtime +${DAILYMAXAGE} -exec rm {} \;
#    
#}
#


#
# END
#
