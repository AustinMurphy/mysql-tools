#!/bin/bash
#
# dump all listed databases into individual "sql" files, compressed 
#
# usage:   hot-indy-backup.sh  [tag]
# 

UTILDIR='/home/mysql/util'
# used from above:
#    bk-common.sh
#    backup.cnf
#    listdb.sh


# Source common options & routines
. $UTILDIR/bk-common.sh



#
#  Backup settings 
# 

# Could use more testing:
#  Options for mysqldump  -- should this be in the backup.cnf?
DUMPOPTS="--net_buffer_length=16M --max_allowed_packet=200M --quick --opt  --extended-insert=FALSE "

# list of Databases to exclude, by default all DBs are backed up
EXCLUDES="information_schema test"

# note gme_evals and ume_evals are huge and need to be backed up separately.



# Set a tag to label this round of backups
#
# Tag logic:
# 
#  - If a tag is passed from the commandline, we use that tag
#  - If we have 0 monthlies from the last 31 days, then we use the tag monthly
#  - If it is the first of the month, then we use the tag monthly
#  - If we have 0 weeklies from the last 7 days, then we use the tag weekly
#  - If it is saturday, then we use the tag weekly
#  - Otherwise, we use the tag daily

# Day of Week,  0 - Sun , 1-Mon, ..., 6-Sat
DOW=$(date +%w)
#  Day of Month
DOM=$(date +%d)
# Number of daily|monthly backups in the past 7|31 days  
NWP7=$( find ${BACKUPDIRBASE}/ -regex '.*weekly.*' -mtime -7 | wc -l)
NMP31=$( find ${BACKUPDIRBASE}/ -regex '.*monthly.*' -mtime -31 | wc -l)

TAG="daily" 

if [ $DOW -eq 6 ] 
then
    TAG="weekly"
fi
if [ $NWP7 -eq 0 ] 
then
    TAG="weekly" 
fi

if [ $DOM -eq 1 ] 
then
    TAG="monthly" 
fi

if [ $NMP31 -eq 0 ]
then
    TAG="monthly" 
fi

[[ X$1 != "X" ]] && TAG=$1


#echo "DOW: $DOW,  DOM: $DOM,  NWP7: $NWP7,  NMP31: $NMP31,  TAG:  $TAG"

#
# mysql username, password (and misc config if necessary) for the backup user 
#
BKUPCNF="$UTILDIR/backup.cnf"


# convert to egrep exclude pattern
EXCLPATT=""
for e in $EXCLUDES 
do
  if [ "X$EXCLPATT" == "X" ]
  then
    EXCLPATT=$e
  else
    EXCLPATT="$EXCLPATT|$e"
  fi
done

#echo "pattern for egrep: $EXCLPATT"
#echo " length: ${#EXCLPATT}"


# collect list of all databases and filter out the ones we want to exclude
LISTDB=$($UTILDIR/listdb.sh | grep -v -E "$EXCLPATT")

# condense long list into  80 col lines 
DATABASES=""
DBLINE=""
for d in $LISTDB 
do
  if [ $(( ${#DBLINE} + ${#d} )) -ge 78 ]
  then
    DATABASES=$(echo -e "$DATABASES\n$DBLINE")
    DBLINE=""
  fi 
  DBLINE="$DBLINE $d"
done
DATABASES=$(echo -e "$DATABASES\n$DBLINE")



BACKUPDIR="$BACKUPDIRBASE/$DATE"


display_backup_settings() {
    echo ""
    echo ""
    echo "      Backup Settings"
    echo ""
    echo "        Tag: $TAG"
    echo "   Location: $BACKUPDIR"
    echo "Backup conf: $BKUPCNF"
    echo "  Dump Opts: $DUMPOPTS"
    echo ""
    echo "  Databases: "
    echo "             $DATABASES"
    #echo "---------------------------"
    hr
    echo ""
    echo ""
}



#
# Run the backups
# 


run_backups() {

    
    # Create today's backup destination directory
    su mysql -l -c "mkdir $BACKUPDIR"
    
    echo ""
    echo "   Running the Individual Backups "
    echo ""
    hr

    
    # dump each DB individually 
    for DB in $DATABASES 
    do
    
        #echo ""
        #echo "---------------------------"
        #hr
        
        DUMPFILE=${BACKUPDIR}/backup.${TAG}.${DB}.${DATE}.sql.gz
        #echo "  Dump File: $DUMPFILE"
        #echo "---------------------------"
    
        # This makes the restore run faster, but requires COMMIT; at the end
        su mysql -l -c "echo \"SET AUTOCOMMIT = 0;\" | gzip -c  > ${DUMPFILE}"
        
        #
        # Do the backup
        #
        
        STARTTIME=$(date)
        #echo ""
        echo "*** $STARTTIME - $DB - START - $DUMPFILE"
        #echo "************ mysqldump start time: $STARTTIME"
        #echo ""
        #echo "******** mysqldump command output:"
        
        su mysql -l -c "mysqldump \
           --defaults-extra-file=$BKUPCNF \
           ${DUMPOPTS} \
           ${DB} | \
        gzip -c >>  ${DUMPFILE} "
        
        # required when autocommit is off
        su mysql -l -c "echo \"COMMIT;\" | gzip -c  >> ${DUMPFILE}"
    
    
    
        ENDTIME=$(date)
        #echo ""
        #echo "************ mysqldump end time: $ENDTIME"
        echo "*** $ENDTIME - $DB - END"
    
        # the idea here was to let the filesystem "settle down" and then show the size of the dump file
        sleep 1
        #sleep 2
        #echo "Dump File: "
        #ls -l $DUMPFILE
        
        
    done
    
    
} 
    
    
    
    
    
    



#
#  Do everything
# 


hr
#echo "----------------------------------------"
echo ""
echo "     MySQL hot indy backup job report    "
echo ""
#echo "----------------------------------------"
hr


display_header


display_disk_usage


display_backup_settings


run_backups




# let the filesystem catch up
sleep 2
display_disk_usage


echo ""
echo ""
echo "*******************************************************"
#echo ""


#
#  END
#



