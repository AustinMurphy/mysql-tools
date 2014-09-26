#!/bin/bash
#
# dump just the listed database into an "sql" file, compressed 
#
#   ./hot-single-backup.sh  dbname
#

# set a tag like daily, weekly, ... 
TAG=single

if [[ "X$1" == "X" ]]  
then
    echo "No Database name given! "
    echo ""
    echo " usage:   ./hot-single-backup.sh  dbname  "
    echo ""
    exit
fi
GIVENDB=$1




#BACKUPDIRBASE='/mnt/filer1/somapps_backup'
#DATE=`date +%Y%m%d-%H%M`

UTILDIR='/home/mysql/util'
BKUPCNF="$UTILDIR/backup.cnf"

# Source common options & routines
. $UTILDIR/bk-common.sh



# Create today's backup destination directory
BACKUPDIR="$BACKUPDIRBASE/$DATE"

MBUSED=$(du -hs $BACKUPDIRBASE | awk '{print $1}')
MBFREE=$(df -hP $BACKUPDIRBASE | grep -v "^Filesystem" | awk '{print $4}')

su mysql -l -c "mkdir $BACKUPDIR" 2>/dev/null >/dev/null



# Could use more testing:
#
DUMPOPTS="--net_buffer_length=16M --max_allowed_packet=200M --quick --opt  --extended-insert=FALSE "


#
# make sure that the given database exists
#
DBNUM=0
DATABASES=$($UTILDIR/listdb.sh | grep "^${GIVENDB}$")
for D in $DATABASES 
do
  (( DBNUM++ ))
done
if [[ $DBNUM > 1 ]]
then
    echo ""
    echo "More than one database by that name. "
    echo ""
    exit
elif [[ $DBNUM -eq 0 ]]
then
    echo "No such database:  $GIVENDB "
    echo ""
    echo "   FYI - Use  $UTILDIR/listdb.sh  to get a list of databases."
    echo ""
    exit
fi


#  General info
# 
echo "---------------------------"
echo "       Date: $DATE"
echo "   Hostname: $HOSTNAME"
echo "---------------------------"
echo " Backup Dir: $BACKUPDIR"
echo "  Disk Used: $MBUSED"
echo "  Disk Free: $MBFREE"
echo "---------------------------"
echo "Backup conf: $BKUPCNF"
echo "  Dump Opts: $DUMPOPTS"
echo "   Database: $DATABASES"
echo "---------------------------"
echo ""


for DB in $DATABASES 
do

    echo ""
    echo "---------------------------"
    
    DUMPFILE=${BACKUPDIR}/backup.${TAG}.${DB}.${DATE}.sql.gz
    echo "  Dump File: $DUMPFILE"
    echo "---------------------------"

    # This makes the restore run faster, but requires COMMIT; at the end
    su mysql -l -c "echo \"SET AUTOCOMMIT = 0;\" | gzip -c  > ${DUMPFILE}"
    
    #
    # Do the backup
    #
    
    STARTTIME=$(date)
    echo ""
    echo "************ mysqldump start time: $STARTTIME"
    echo ""
    echo "******** mysqldump command output:"
    
    su mysql -l -c "mysqldump \
       --defaults-extra-file=$BKUPCNF \
       ${DUMPOPTS} \
       ${DB} | \
    gzip -c >>  ${DUMPFILE} "
    
    # required when autocommit is off
    su mysql -l -c "echo \"COMMIT;\" | gzip -c  >> ${DUMPFILE}"



    ENDTIME=$(date)
    echo ""
    echo "************ mysqldump end time: $ENDTIME"

    # the idea here was to let the filesystem "settle down" and then show the size of the dump file
    sleep 1
    #sleep 2
    #echo "Dump File: "
    #ls -l $DUMPFILE
    
    
done



#
# Post-script
#

# let the filesystem catch up
sleep 5

MBUSED=$(du -h $BACKUPDIR | awk '{print $1}')
MBFREE=$(df -hP $BACKUPDIR | grep -v "^Filesystem" | awk '{print $4}')
echo ""
echo ""
echo " Backup directory:  $BACKUPDIR "
echo ""
echo ""
echo "---------------------------"
echo " Disk Used now: $MBUSED"
echo " Disk Free now: $MBFREE"
echo "---------------------------"
echo ""
echo ""
echo "*******************************************************"
echo ""

#
#  END
#


