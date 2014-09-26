#!/bin/bash
#
#    Usage:  newuserpass.sh  dbuser
# 
#  dbuser: the user account to get a new password
#
#
#


#
# the prep
#  


DBUSER=$1

if [ $# -eq 0 ]
then
  echo "Usage:  newuserpass.sh  dbuser "
  echo "Sets a new password for DB user \"dbuser\" "
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
UPDATE mysql.user SET Password=PASSWORD('${PASSWORD}') WHERE User='${DBUSER}';
FLUSH PRIVILEGES;
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
