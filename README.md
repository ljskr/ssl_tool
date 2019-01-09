# ssl_tool

使用 openssl 生成 ssl 证书示例工具

## ssl 证书相关知识

### 证书相关知识

一般来说，申请证书的步骤是：
1. 创建一个私钥(key)文件。
2. 根据私钥生成一个证书签名请求(csr， Certificate Signing Request)文件。
3. 把请求文件提交给权威的证书颁发机构，颁发机构审核通过之后，再根据这些申请信息生成相应的证书。(crt， certificate 文件)

证书颁发机构用于给别人签署的证书属于 CA 证书，只要 CA 证书受信任，则 CA 证书签署过的证书也会受信任。

而自己给自己签署的证书称为自签署证书，可以当作 CA 证书来使用。只是使用前需要手动加入浏览器等软件的证书信任列表中。

### 使用 openssl 创建证书全过程（简单模式）

#### 1. 创建私钥(key)

```bash
# 输出 key 密钥文件。以下方法任选一。

openssl genrsa -out my.key 2048   # 证书长度为 2048 字节

# 或者 ecc 算法密钥
openssl ecparam -genkey -name prime256v1 -out my.key  # 使用 prime256v1 算法

# 如需要加密密钥。加密时需要设定密码，后续每次使用私钥都要输入密码，适合于ca使用。
# rsa
openssl genrsa -aes256 -out my.key 2048 # 使用 aes256 加密，其他可选: -des3
# ecc，在上面密钥的基础上，运行下面命令
openssl ec -aes256 -in my.key -out my_enc.key
```

#### 2. 生成签名请求(csr)

```bash
# 输入 key 文件， 输出 csr 请求文件。

openssl req -new -key my.key -out my.csr
```

#### 3. 签署证书(crt)

这里分两种情况：

3.1) 自签署（可以作为 ca 证书使用）
```bash
# 输入 csr 请求文件，指定签署的 key，输出证书 crt 文件。

openssl x509 -req -sha256 -days 3650 -in my.csr -signkey my.key -out my.crt     # days 是证书有效天数
```

3.2) 使用已有的 ca 证书来签署
```bash
# 输入别人给的 csr 请求文件，使用指定 CA 的私钥和证书来签署，输出服务器证书 crt。

openssl x509 -req -sha256 -days 3650 -in my.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out my.crt    # days 是证书有效天数
```

### 使用 openssl 创建证书（更多用法）

上一节的介绍是基于一个证书的完整生成步骤来说的，实际使用时，能有一些更简便的方式。

#### 1. 一句命令生成 key 和自签署证书
```bash
openssl req -x509 -sha256 -days 3650 -newkey rsa:2048 -keyout app.key -out app.crt

# 如果不设置密码，则可以加上 -nodes 参数，如下
# openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 -keyout app.key -out app.crt

# ecc
openssl ecparam -name prime256v1 -out ec.pem  # 使用 prime256v1 算法，先生成参数文件，后一步newkey需要
openssl req -x509 -sha256 -days 3650 -newkey ec:ec.pem -keyout app.key -out app.crt
```

#### 2. 通过配置文件，非交互式生成证书请求文件(CSR)
上面的例子中，生成证书信息时，会在终端交互式地需要手动输入国家、组织名称等，其实可以通过配置文件，或者参数，进行非交互式生成证书请求文件。

首先，创建一个配置文件 my.conf，示例如下:
```config
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = req_distinguished_name
 
[req_distinguished_name]
C  = CN
ST = GuangDong
L  = ShenZhen
O  = your_company
OU = your_org
CN = *.myserver.com
emailAddress = your@test.com
```
然后通过 -config 参数指定配置信息
```bash
# 指定配置文件，此时不会出现交互模式，相交信息自动设置。

openssl req -new -key my.key -out my.csr -config my.conf
```

也可以通过参数直接指定，示例如下：
```bash
openssl req -new -key my.key -out my.csr -subj "/C=CN/ST=GuangDong/L=ShenZhen/O=your_company/OU=your_org/CN=test.com/emailAddress=your@test.com"
```

## 本脚本使用说明

本工具通过以上知识，把相应的参数作好设置，达到快速生成证书的目的。

### 1. 生成 ca 证书

编辑 ca.conf 文件，根据需要修改相应的位置和组织信息，然后进行运行 gen_new_ca_cert.sh 即可。

### 2. 生成服务器证书

本脚本默认的目录结构如下：
```
.
|--script
|--ca
|  |--ca.key
|  └--ca.crt
└--server
```
其中， script目录存放本仓库里的所有脚本。ca目录及里面的ca.key、ca.crt 使用以上生成ca证书脚本提前准备好。server目录是存放待生成的证书文件。

首先，把本仓库中的 v3_sample.ext 文件拷贝出来，并重命令为 v3.ext
```bash
cd server
cp ../script/v3_sample.ext ./v3.ext
```
编辑 v3.ext 文件，在DNS列表中加入所有待支持的域名。

然后执行
```bash
# 请提前修改该脚本里的组织信息

../script/gen_new_server_cert.sh test.com server        # 第一个参数为证书的 CN ， 第二个参数为生成的证书名称
```

此时目录下会生成 server.key、server.csr、server.crt 三个文件。

最终目录结构如下：
```
.
|--script
|--ca
|  |--ca.key
|  └--ca.crt
└--server
   |--v3.ext
   |--server.key
   |--server.csr
   └--server.crt
```


