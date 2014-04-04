#!/bin/bash

#
#  This script does not delete anything, 

#   it just gathers info using the same code as the clean up script
#  


UTILDIR=/home/mysql/util

# Source common options
. $UTILDIR/bk-common.sh


# BACKUPDIRBASE=/data/backup
# 
# # TODO: test if it exists
# 
# 
# # normal daily backups are marked with "crondaily" in the backup filename
# 
# # TODO:  establish crondaily, cronweekly, & cronmonthly backups
# 


echo "----------------------------------------"
echo ""
echo "      MySQL backups aging report    "
echo ""
echo "----------------------------------------"


display_header


display_disk_usage


display_age_settings


display_counts


display_empty_dirs


echo ""
echo ""
echo "----------------------------------------"

#
# END
#
