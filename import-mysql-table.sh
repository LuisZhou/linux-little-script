#!/bin/bash

# Preconditions
# 1. install csvsql (awaresome tool) if you need import from csv, create table at the same time.
# 2. mysql-client
# 3. your database use utf-8 as chatset is recommended.

# Careful
# 1. if you want the insert table is using utf-8, you should make your database use utf_general_ci
# 	 as in Collation (Operation->Collation), or the csvsql just using the default encoding of database,
# 	 no matter what you set charset in connect url. I think it is the buy of the csvsql.
# 2. double check if your mysql user has remote access right to your specified database, host name in privileges must 
#		 match your current host.

# example: ./import.sh 192.168.163.133 root CSV_DB ./convert/item_drop.csv

if ( [ $# == 1 ] && [ $1 == '-h' ] ) ||  [ $# -lt 4 ] ; then
	echo "Usage: $0 host username dbname filename [password]"
	exit
fi

filename=$(basename "$4")
tablename="${filename%.*}"
extension="${filename##*.}"

host=$1
user=$2
database=$3
filepath=$4
password=$5

if [ "$extension" != "csv" ] && [ "$extension" != "sql" ] ; then
 echo -e "wrong file type, only support csv or sql\n"
 exit
fi

if [ $# -lt 5 ] ; then
	read -s -p "Password: " password 
	echo -e "\n"
fi

while ! mysql -u $user -p$password -h $host -e ";" ; do
	echo -e "$host\n"
	read -s -p "Can't connect, please retry: " password
	echo -e "\n"
done

# drop table if exist.
mysql --host="$host" --user="$user" --password=$password --database="$database" --execute="DROP TABLE IF EXISTS $tablename;"

if [ "$extension" == "csv" ]; then
	csvsql --db "mysql://$user:$password@$host:3306/$database?charset=utf8" --tables $tablename -e "utf8" --insert $filepath
	mkdir -p 'export'
	mysqldump --max-allowed-packet=512M -h "$host" -u $user -p$password $database $tablename > "./export/$tablename.sql"
else
	# this is using mysqldump, which default is 16M, which is defined in /etc/my.conf	
	# do not need to use --max_allowed_packet=100M
	# ref:
	# https://stackoverflow.com/questions/93128/mysql-error-1153-got-a-packet-bigger-than-max-allowed-packet-bytes
	# how to update csvsql
	mysql -h "$host" -u $user -p$password $database < $filepath	
fi

echo -e "\ndone!"
exit