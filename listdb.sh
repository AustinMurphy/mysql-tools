#!/bin/bash
#
#    Usage:  ./listdb.sh
# 
# 


#
# the prep
#

if [ $# -ne 0 ]
then
  echo "Usage:  listdb.sh  "
  echo "Lists the existing databases "
  exit
fi


#
# the SQL
#

SQL_STATEMENT="\
SHOW DATABASES; "


#
# run it
#

echo $SQL_STATEMENT  | mysql --silent
MYSQLSTAT=$?

if [ $MYSQLSTAT -ne '0' ]
then
  echo ""
  echo "FAILURE"
  echo ""
fi


#
# END
#
