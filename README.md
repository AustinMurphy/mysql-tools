mysql-tools
===========

Shell scripts for managing MySQL
Austin's tools for MySQL
------------------------

DBs & Users:
 - listdb.sh
 - listdbuser.sh
 - mkdb.sh
 - mkdbuser.sh
 - mkdbrouser.sh 


Backups: 
 - hot-indy-backup.sh
 - hot-single-backup.sh
 - backups-aging-report.sh
 - clean-up-backups.sh



General pre-reqs:

 - working mysql
 - ~/.my.cnf with mysql root creds  (looks like this:)

  [client]
  user     = root
  password = 'XXXXXXXXXXXXXXXXXX'




Backup scheme setup instructions:

  pre-reqs:
   - bash
   - mysqldump
   - gzip


- create a readonly backup user 
     ./mkdbrouser.sh backup mysql
  - grant it permissions to read everything
     mysql> GRANT SELECT, FILE, SHOW DATABASES, CREATE TEMPORARY TABLES, LOCK TABLES, REPLICATION SLAVE, REPLICATION CLIENT, SHOW VIEW ON *.* TO 'backup'@'%';

- edit backup.cnf 
  - store the backup user's credentials
  - use the correct connection method

- edit bk-common.sh  
  - establish a dumps destination directory
  - establish the retention periods

- run a test backup job (or 3)
  - verify that the location makes sense
  
- add backup script to cron
  - run it once nightly (it will decide how to label the backups)

- test the backups aging report

- wait for lots of backups to accumulate

- test the clean up script

- add the clean up script to cron

- periodically check the aging report
  - verify that there is sufficient space for backups, etc.



