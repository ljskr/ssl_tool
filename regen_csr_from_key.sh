#!/bin/bash
# Author: Liujun
# Date: 2018-07-10
# Descript: 根据 key 文件重新 csr 文件。


print_help()
{
    echo "usage:  regen_csr_from_key.sh <key_file_name> <csr_file_name> <common_name>"
}

if [[ -z $1 || -z $2 || -z $3 ]]; then
    echo "缺少参数!"
    print_help
    exit
fi

if [ $1 = "-h" ]; then
    print_help
    exit
fi

KEY_FILE=$1
CSR_FILE=$2


C="CN"
ST="GuangDong"
L="ShenZhen"
O="Your Organization Name"
OU="Your Organizational Unit Name"
CN="$3"
emailAddress="admin@example.com"


# openssl genrsa -out $1.key 2048
# openssl req -new -key $1.key -out $1.csr -config ../req.conf

# openssl req -new -sha256 -nodes -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CSR_FILE} -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${emailAddress}"
openssl req -new -sha256 -nodes -key ${KEY_FILE} -out ${CSR_FILE} -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${emailAddress}"
