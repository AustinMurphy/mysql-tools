#!/bin/bash
#
#    Usage:  mkdbnogrants.sh  dbname
# 
#


#
# the prep
#


DBNAME=$1

if [ "${DBNAME}" == "" ] 
then 
  echo "No DB name given"
  exit
else
  DB=${DBNAME}
fi


if [ $# -eq 0 ]
then
  echo "Usage:  mkdbnogrants.sh  dbname "
  echo "Creates DB \"dbname\" "
  exit
else
  echo "-----"
  echo "DB: $DB"
  echo "-----"
fi


#
# the SQL
#

SQL_STATEMENT="\
CREATE DATABASE IF NOT EXISTS \`${DB}\` 
DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;
"


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
