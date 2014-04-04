#!/bin/bash
#
#    Usage:  mkdbrouser.sh  dbuser db
# 

#
# the prep
#  

DBUSER=$1
DB=$2

if [ $# -ne 2 ]
then
  echo "Usage:  mkdbrouser.sh  dbuser db "
  echo "Creates DB user \"dbuser\" with Read-Only privs on \"db\". "
  exit
else
  echo "User: $DBUSER  "
fi

stty -echo
echo -n "Enter mysql passwd for ${DBUSER}: "
read PASSWORD
stty echo
echo ""


#
# the SQL
#

# disable pathname expansion on *'s in SQL statement
set -f

SQL_STATEMENT="\
CREATE USER '${DBUSER}'@'%'
IDENTIFIED BY '${PASSWORD}' ; 
GRANT USAGE ON *.* TO '${DBUSER}'@'%' 
IDENTIFIED BY '${PASSWORD}' WITH 
MAX_QUERIES_PER_HOUR 0 
MAX_CONNECTIONS_PER_HOUR 0 
MAX_UPDATES_PER_HOUR 0 
MAX_USER_CONNECTIONS 0 ; 
GRANT SELECT, CREATE TEMPORARY TABLES, SHOW VIEW 
ON \`${DB}\`.* TO '${DBUSER}'@'%' ;
"


#
# run it
#

echo "-----"

# username (root) and password are now stored in a file
echo $SQL_STATEMENT  | mysql 
MYSQLSTAT=$?

if [ $MYSQLSTAT -eq '0' ]
then
  echo ""
  echo "SUCCESS"
  echo ""
fi

#
# End
#

