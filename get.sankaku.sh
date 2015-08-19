#!/bin/bash

# ���������
uag="Mozilla/5.0 (Windows NT 6.3; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0"

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

# ��������� ������ � ������

if [ -f ~/.config/boorulogins.conf ]
then
  . ~/.config/boorulogins.conf
else
  echo ���� � ������� ��� ����������� �� ������!
  echo �������� ���� ~/.config/boorulogins.conf � ��������� � ���� ��������� ������:
  echo sanlogin=��� �����
  echo sanpass=��� ������
  exit 5
fi

# ��������� (���� � sankaku.txt)
echo Logging in...
ATH=`curl -s -c sankaku.txt -F"commit=Login" -F"user[name]=${sanlogin}" -F"user[password]=${sanpass}" https://chan.sankakucomplex.com/user/authenticate`

# �������� ������
checklog=`cat sankaku.txt |grep pass_hash|wc -l`
if [ $checklog -eq 0 ]
then
  echo ERROR: ��������� ����� � ������
  rm sankaku.txt
  exit 2
else
  echo OK
fi

# �������� ������� ������
if [ -e get.sankaku.txt ]
then
  rm -f get.sankaku.txt
fi

# �������� �� ��� ���, ���� � ������ ����� 0 ������
pagenum=1
picnum=1

until [ $picnum -eq 0 ]
do
  # ��������� ������
  wget --no-check-certificate --load-cookies=sankaku.txt "https://chan.sankakucomplex.com/post/index.json?tags=$tags&page=$pagenum" -O out.dat --referer="https://chan.sankakucomplex.com/" -U "$uag"
  cat out.dat | pcregrep -o -e 'file_url\":\"[^\"]+'|sed -e 's/\"//g' -e 's/file_url/https/g' -e 's/\?.*//g' > tmp.sankaku.txt
  # cat out.dat | pcregrep --buffer-size=1M -o -e 'file_url\":\"[^\"]+'|sed -e 's/\"//g' -e 's/file_url/https/g' -e 's/\?.*//g' > tmp.sankaku.txt
  picnum=`cat tmp.sankaku.txt|wc -l`
  if [ $picnum \> 0 ]
  then
    cat tmp.sankaku.txt >> get.sankaku.txt
    let "pagenum++"
  fi
done;

# �������� ����������
postcount=`cat get.sankaku.txt|wc -l`

if [ $postcount -eq 0 ]
then
  echo �� ��������� "$tags" ������ �� �������.
  exit 3
else
  echo �� ��������� "$tags" ������� ������: $postcount
fi

wget --random-wait --no-check-certificate -nc -i get.sankaku.txt -U "$uag"

# ������� �� �����
rm -f tmp.sankaku.txt sankaku.txt out.dat
