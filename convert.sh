#!/bin/bash

#File common can not get the correct encoding for iconv. Just use chardet
#CHARSET="$(file -bi "$1"|awk -F "=" '{print $2}')"

# 'chardet -l' to list all support character.
# GBK is an extension of the GB2312 character set for simplified Chinese characters
# use GBK OR GB2312 is same for some file.

# Example output of chardet: 'box.csv: GB2312 with confidence 0.360492711041'
CHARSET="$(chardet "$1" | awk -F ":" '{print $2}'  | awk -F "with" '{print $1}')"
mkdir -p ./convert

if [ "$CHARSET" != utf-8 ]; then
	iconv -f "$CHARSET" -t utf8 "$1" -o ./convert/$1
fi

dos2unix ./convert/$1  2> /dev/null

sed -i -e 1d ./convert/$1
sed -i -e 2d ./convert/$1

echo "convert done!"
