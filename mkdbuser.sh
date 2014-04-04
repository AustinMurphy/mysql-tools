#!/bin/bash
#
#    Usage:  mkdbuser.sh  dbuser
# 
#  dbuser: the user account to be created
#
#
#


#
# the prep
#  


DBUSER=$1

if [ $# -eq 0 ]
then
  echo "Usage:  mkdbuser.sh  dbuser "
  echo "Creates DB user \"dbuser\" with no privs"
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
MAX_USER_CONNECTIONS 0 ; "


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
  echo "    You might want to run:   mkdb.sh $DBUSER "
  echo "    (or something similar)"
  echo ""
fi

#
# End
#
