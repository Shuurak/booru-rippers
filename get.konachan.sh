#!/bin/bash

# ���������
uag="Mozilla/5.0 (Windows; U; Windows NT 5.1; ru; rv:1.9.1.1) Gecko/20090715 Firefox/3.5.1 (.NET CLR 3.5.30729)"

# �������� ����������
if [ ! "$2" = "" ]
then
  tags=$1
  savedir=$2
else
  if [ ! "$1" = "" ]
  then
    tags=$1
    savedir=$1
  else
    echo �������������:
    echo `basename $0` ���� \[�������\]
    exit 1
  fi
fi

# ������� ��� �������
if [ ! -d $savedir ]
then
  echo Creating $savedir
  mkdir "$savedir"
fi
echo Entering $savedir
cd "$savedir"

# ���������� ������
postcount=`curl -# "http://konachan.com/post/index.xml?tags=$tags&limit=1" -A "$uag"|pcregrep -o 'posts\ count=\"[^"]+'|sed -e 's/posts\ count=//' -e 's/\"//'`

# �������� ����������
if [ $postcount -eq 0 ]
then
  echo �� ��������� "$tags" ������ �� �������.
  exit 3
else
  echo �� ��������� "$tags" ������� ������: $postcount
fi

# �������� �����-������
if [ -e get2.konachan.txt ]
then
  rm -� get2.konachan.txt
fi

let "pcount=postcount/1000+1"

for ((i=1; i<=$pcount; i++))
do
  curl "http://konachan.com/post/index.xml?tags=$1&limit=1000&page=$i" -A "$uag" |pcregrep -o -e 'file_url=[^ ]+'|sed -e 's/file_url=//g' -e 's/\"//g'  >>get2.konachan.txt
done;

# ��������� ������
cat get2.konachan.txt |sed 's/\/Konachan.*//g' > get2.konachan.md5.txt
cat get2.konachan.txt | awk -F "." '{print $(NF) }' > get2.konachan.ext.txt
# ����������
paste -d "." get2.konachan.md5.txt get2.konachan.ext.txt > get2.konachan.txt

wget -nc -i get2.konachan.txt

rm -f get2.konachan.*.txt
