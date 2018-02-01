#!/bin/bash

# Careful: If you want the insert table is using utf-8, you should make your database use utf_general_ci
# as in Collation (Operation->Collation), or the csvsql just using the default encoding of database,
# no matter what you set charset in connect url. I think it is the buy of the csvsql

# example: ./import.sh 192.168.163.133 root CSV_DB ./convert/item_drop.csv

if [ $# != 4 ] ; then
	echo 'usage: ./import.sh host username dbname filename.csv' $#
	exit
fi

filename=$(basename "$4")
tablename="${filename%.*}"
echo "$tablename"

host=$1
user=$2
database=$3
filepath=$4

read -s -p "Password: " password 
echo -e "\n"

while ! mysql -u $user -p$password -h $host -e ";" ; do
	echo -e "\n"
	read -s -p "Can't connect, please retry: " password
	echo -e "\n"
done

mysql --host="$host" --user="$user" --password=$password --database="$database" --execute="DROP TABLE IF EXISTS $tablename;"

csvsql --db "mysql://$user:$password@$host:3306/$database?charset=utf8" --tables $tablename -e "utf8" --insert $filepath

mkdir -p 'export'
mysqldump -h "$host" -u $user -p$password $database $tablename > "./export/$tablename.sql" 
