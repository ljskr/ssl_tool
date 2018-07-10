#!/bin/bash
# Author: Liujun
# Date: 2018-07-10
# Descript: 根据 csr 文件重新生成证书。


print_help()
{
    echo "usage:  regen_server_cert_from_csr.sh <csr_file_name> <cert_file_name>"
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

CSR_FILE=$1
CERT_FILE=$2


openssl x509 -req -sha256 -days 3650 -CA ../ca/ca.crt -CAkey ../ca/ca.key -CAcreateserial -in ${CSR_FILE} -out ${CERT_FILE} -extfile v3.ext

# show the info of new cert
openssl x509 -text -in ${CERT_FILE} -noout
