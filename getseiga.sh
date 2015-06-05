#!/bin/bash

# ������ ������

seigaid='�����'
seigapass=������

# ����� ��� ���������� ���� ������_�����_�����/���

dirlet=`echo $2|cut -c-1`
if [ ! -d seiga/${dirlet,,}/$2 ]
then
echo Creating seiga/${dirlet,,}/$2
mkdir -p "seiga/${dirlet,,}/$2"
fi
echo Entering seiga/${dirlet,,}/$2
cd seiga/${dirlet,,}/$2

# ����� �� �������� ������
echo \[InternetShortcut\] > "$2.url"
echo URL=http\:\/\/seiga\.nicovideo\.jp\/user\/illust\/$1\?target=illust_all >> "$2.url"

# ��������� � ��������� ����

curl -k -s -c niko.txt -F"mail=${seigaid}" -F"password=${seigapass}" "https://secure.nicovideo.jp/secure/login?site=seiga"

# ����� �� ���� ������� ������������� ��������

echo "seiga.nicovideo.jp	FALSE	/	FALSE	4564805162	skip_fetish_warning	1" >> niko.txt

# ���������� ��� ��������

picnum=1
pagenum=1
athid=$1

until [ $picnum -eq 0 ]
do
wget "http://seiga.nicovideo.jp/user/illust/$athid?page=$pagenum&target=illust_all" --load-cookies=niko.txt -O - |pcregrep -o -e 'lohas\.nicoseiga\.jp\/\/thumb\/[^q]+'|pcregrep -o -e '\d+'|awk '{ print "http://seiga.nicovideo.jp/image/source/"$0 }' > out.txt
  picnum=`cat out.txt|wc -l`
  # ���� ���-�� ���������
  if [ $picnum \> 0 ]
  then
    # ����������
    cat out.txt >> get.seiga.all.txt
    let "pagenum++"
  fi
done;

# ��������� ��� ���������

ls *.jp*g *.png *.gif|sed 's/\..*//g'|sort > pres.txt
basename -a `cat get.seiga.all.txt`|sort > all.txt
comm -2 -3 all.txt pres.txt  | awk '{ print "http://seiga.nicovideo.jp/image/source/" $0 }' > get.seiga.all.txt


# ������
if [ -s get.seiga.all.txt ]
then
  # �������� URL �����������
  cat get.seiga.all.txt|xargs -l1 curl -b niko.txt -D - | grep Location > loclist.txt
  # ������� ��� awk
  dos2unix loclist.txt
  # ���������� ���������� jpg ��� ���� ������
  cat loclist.txt| pcregrep -o -e 'http.+'|sed 's#/o/#/priv/#g'|awk -F"/" '{ print $0" -O "$NF".jpg" }' > list.txt
  # cat loclist.txt| pcregrep -o -e 'http.+'|sed 's#/o/#/priv/#g' > list.txt
  # ����������
  cat list.txt|xargs -t -l1 wget --load-cookies=niko.txt -nc
  # wget --content-disposition --load-cookies=niko.txt -nc -R "http://lohas.nicoseiga.jp/" -i list.txt
fi

# ������� �����
if [ ! $3 ]
then
  rm -rf out.txt get.seiga.all.txt niko.txt list.txt loclist.txt pres.txt all.txt
fi
