#!/bin/bash
# Author: Liujun
# Date: 2018-07-10
# Descript: 无需交互生成新的证书。


print_help()
{
    echo "usage:  gen_new_server_cert.sh <common_name> <cert_name>"
}

if [[ -z $1 || -z $2 ]]; then
    echo "缺少参数!"
    print_help
    exit
fi

if [ $1 = "-h" ]; then
    print_help
    exit
fi

FILENAME=$2
KEY_FILE=${FILENAME}.key
CSR_FILE=${FILENAME}.csr
CERT_FILE=${FILENAME}.crt


C="CN"
ST="GuangDong"
L="ShenZhen"
O="Your Organization Name"
OU="Your Organizational Unit Name"
CN="$1"
emailAddress="admin@example.com"


# openssl genrsa -out $1.key 2048
# openssl req -new -key $1.key -out $1.csr -config ../req.conf

if [ ! -f "prime256v1.pem" ];then
  echo "=> generate prime256v1 param file for ecc."
  openssl ecparam -name prime256v1 -out prime256v1.pem
fi

openssl req -new -sha256 -nodes -newkey ec:prime256v1.pem -keyout ${KEY_FILE} -out ${CSR_FILE} -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${emailAddress}"

openssl x509 -req -sha256 -days 3650 -CA ../ca/ca.crt -CAkey ../ca/ca.key -CAcreateserial -in ${CSR_FILE} -out ${CERT_FILE} -extfile v3.ext

# show the info of new cert
openssl x509 -text -in ${CERT_FILE} -noout
