#!/bin/bash
#
#    Usage:  listdbuser.sh
# 
#  Returns a list of existing users in the Database
#


if [ $# -ne 0 ]
then
  echo "Usage:  listdbuser.sh  "
  echo "Lists the existing database users "
  exit
fi


#
# the SQL
#

#SELECT user FROM mysql.user;

SQL_STATEMENT="\
SELECT user,host FROM mysql.user;
"


#
# run it
#


echo $SQL_STATEMENT  | mysql --silent  | sort
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
