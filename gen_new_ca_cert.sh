#!/bin/bash
# Author: Liujun
# Date: 2018-07-10
# Descript: 生成新的 ca 证书。


print_help()
{
    echo "usage:  gen_new_ca_cert.sh"
}

# if [[ -z $1 || -z $2 ]]; then
#     echo "缺少参数!"
#     print_help
#     exit
# fi

if [[ $1 = "-h" ]]; then
    print_help
    exit
fi

FILENAME="new_ca"
KEY_FILE=${FILENAME}.key
CSR_FILE=${FILENAME}.csr
CERT_FILE=${FILENAME}.crt


# 方法一：
# 分两步生成 key 和 csr
# openssl genrsa -out ca_new.key 2048
# openssl req -new -key ca_new.key -out ca_new.csr -config ../ca.conf

# 一步生成 key 和 csr
# openssl req -new -sha256 -nodes -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CSR_FILE} -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${emailAddress}"

# 自签署证书
# openssl x509 -req -days 3650 -in ${CSR_FILE} -signkey ${KEY_FILE} -out ${CERT_FILE}

# 方法二：
# 一步生成 key 和自签署证书。
# private key with password
openssl req -x509 -sha256 -days 3650 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -config ca.conf
# private key without password
# openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -config ca.conf

# show the info of new cert
openssl x509 -text -in ${CERT_FILE} -noout
