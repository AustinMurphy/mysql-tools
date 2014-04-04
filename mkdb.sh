#!/bin/bash
#
#    Usage:  mkdb.sh  dbuser  [dbname]
# 
#  Database user account must exist - does NOT get created by this script
#

#  TODO:
# 
# actually if a DB user does not yet exist, it DOES get created.  
# That's bad, maybe.  
# The script should check for an existing user and complain if the specified user does not exist

#
# the prep
#


DBUSER=$1
DBNAME=$2

if [ "${DBNAME}" == "" ] 
then 
  DB=${DBUSER}
else
  DB=${DBNAME}
fi


if [ $# -eq 0 ]
then
  echo "Usage:  mkdb.sh  dbuser  [dbname]"
  echo "Creates DB \"dbname\" (or \"dbuser\" if no dbname given), and grants all privs to dbuser"
  exit
else
  echo "-----"
  echo "User: $DBUSER  -- DB: $DB"
  echo "-----"
fi


#
# the SQL
#

SQL_STATEMENT="\
CREATE DATABASE IF NOT EXISTS \`${DB}\` 
DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ; 
GRANT ALL PRIVILEGES ON \`${DB}\`.* 
TO '${DBUSER}'@'%' "


#
# run it
#

echo $SQL_STATEMENT  | mysql 
MYSQLSTAT=$?

if [ $MYSQLSTAT -eq '0' ]
then
  echo ""
  echo "SUCCESS"
  echo ""
fi


#
# END
#
