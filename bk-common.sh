#
# This is not a file to run, 
# it should be sourced into the real scripts to establish commonality
#

BACKUPDIRBASE=/data/backup/mysql


# Applies to cleanup and aging scripts:

SINGLESMAXAGE=21
DAILYMAXAGE=31
WEEKLYMAXAGE=120
MONTHLYMAXAGE=500

# All ages are in days (and passed to the find command)


# 
#  ==========================
#  

# Now
DATE=`date +%Y%m%d-%H%M`


hr() {
    echo "----------------------------------------"
}

display_age_settings(){

    echo ""
    echo ""
    #echo "---------------------------"
    echo "      Max age (days) "
    echo "    of backups to retain "
    echo ""
    echo "    Singles: $SINGLESMAXAGE "
    echo "      Daily: $DAILYMAXAGE "
    echo "     Weekly: $WEEKLYMAXAGE "
    echo "    Monthly: $MONTHLYMAXAGE "
    #echo "----------------------------------------"
    hr

}


display_header () {

    echo ""
    echo ""
    echo "       Date: $DATE"
    echo "   Hostname: $HOSTNAME"
    echo ""
    #echo "----------------------------------------"
    hr

}

get_disk_usage() {
    

    MBUSED=$(du -hs $BACKUPDIRBASE | awk '{print $1}')
    MBFREE=$(df -hP $BACKUPDIRBASE | grep -v "^Filesystem" | awk '{print $4}')
    
}


display_disk_usage() {

    get_disk_usage

    echo ""
    echo ""
    #echo "---------------------------"
    echo "      Disk Usage in"
    echo "     backup directory"
    echo ""
    echo " Backup Dir Base: $BACKUPDIRBASE"
    echo "       Disk Used:  $MBUSED"
    echo "       Disk Free:  $MBFREE"
    #echo "----------------------------------------"
    hr
    #echo ""
    #echo ""

}


count_backups() {

    #
    #  Determine how many backups exist of each type
    # 

    SINGLES=$(find ${BACKUPDIRBASE}/ -regex '.*single.*sql\.gz' | wc -l)
    DAILYS=$(find ${BACKUPDIRBASE}/ -regex '.*daily.*sql\.gz' | wc -l)
    WEEKLYS=$(find ${BACKUPDIRBASE}/ -regex '.*weekly.*sql\.gz' | wc -l)
    MONTHLYS=$(find ${BACKUPDIRBASE}/ -regex '.*monthly.*sql\.gz' | wc -l)
    MANUALS=$(find ${BACKUPDIRBASE}/ -regex '.*manual.*sql\.gz' | wc -l)

    SINGLESOLD=$(find ${BACKUPDIRBASE}/ -regex '.*single.*sql\.gz' -mtime +${SINGLESMAXAGE} | wc -l)
    DAILYSOLD=$(find ${BACKUPDIRBASE}/ -regex '.*daily.*sql\.gz' -mtime +${DAILYMAXAGE} | wc -l)
    WEEKLYSOLD=$(find ${BACKUPDIRBASE}/ -regex '.*weekly.*sql\.gz' -mtime +${WEEKLYMAXAGE} | wc -l)
    MONTHLYSOLD=$(find ${BACKUPDIRBASE}/ -regex '.*monthly.*sql\.gz' -mtime +${MONTHLYMAXAGE} | wc -l)

    TOTAL=$(find ${BACKUPDIRBASE}/ -regex '.*backup.*sql\.gz$' | wc -l)

}

display_counts() {

    count_backups

    echo    ""
    echo    ""
    echo    "   Counts of each type of MySQL backup"
    echo    ""
    echo    "    Type   |    All    |  Past Max Age  "
    echo    "-----------+-----------+----------------"
    echo -n "  SINGLES  | "
    printf  "  %6d  |  %6d\n" $SINGLES $SINGLESOLD
    echo -n "    DAILY  | " 
    printf  "  %6d  |  %6d\n" $DAILYS $DAILYSOLD
    echo -n "   WEEKLY  | "
    printf  "  %6d  |  %6d\n" $WEEKLYS $WEEKLYSOLD
    echo -n "  MONTHLY  | "
    printf  "  %6d  |  %6d\n" $MONTHLYS $MONTHLYSOLD
    echo -n "   MANUAL  | "
    printf  "  %6d  |      -- \n" $MANUALS 
    echo    "-----------+-----------+----------------"
    echo -n "    TOTAL  | "
    printf  "  %6d  \n" $TOTAL
    #echo    ""
    #echo    ""
}




delete_old_backups() {

    #
    #  delete the old ones
    #

    echo    ""
    echo    ""

    echo "Deleting $MONTHLYSOLD Monthly backups more than $MONTHLYMAXAGE days old ... "
    sleep 2
    find ${BACKUPDIRBASE}/ -regex '.*monthly.*sql\.gz' -mtime +${MONTHLYMAXAGE} -exec rm {} \;

    echo "Deleting $WEEKLYSOLD Weekly backups more than $WEEKLYMAXAGE days old ... "
    sleep 2
    find ${BACKUPDIRBASE}/ -regex '.*weekly.*sql\.gz' -mtime +${WEEKLYMAXAGE} -exec rm {} \;

    echo "Deleting $DAILYSOLD Daily backups more than $DAILYMAXAGE days old ... "
    sleep 2
    find ${BACKUPDIRBASE}/ -regex '.*daily.*sql\.gz' -mtime +${DAILYMAXAGE} -exec rm {} \;

    echo "Deleting $SINGLESOLD Single backups more than $SINGLESMAXAGE days old ... "
    sleep 2
    find ${BACKUPDIRBASE}/ -regex '.*single.*sql\.gz' -mtime +${SINGLESMAXAGE} -exec rm {} \;

}


count_empty_dirs() {

    EMPTYDIRS=$(find ${BACKUPDIRBASE}/ -type d -a -empty)
    NUMEMPTYDIRS=$(find ${BACKUPDIRBASE}/ -type d -a -empty | wc -l)


}

display_empty_dirs() {

    count_empty_dirs

    echo ""
    echo ""
    echo "   Empty directories ($NUMEMPTYDIRS):"
    echo ""

    for d in $EMPTYDIRS 
    do
        echo "        $d"
    done
    hr
}


delete_empty_dirs() {

    count_empty_dirs

    echo "Deleting $NUMEMPTYDIRS empty directories ..."
    echo ""
    sleep 1
    find ${BACKUPDIRBASE}/ -mindepth 1 -maxdepth 1 -type d -a -empty -exec rmdir {} \;

    hr
}



