#!/bin/bash
workdir='/opt/pmx'

if [ ! -d $workdir ]; then
    mkdir -p $workdir
else 
    rm -rf $workdir
    mkdir -p $workdir
fi

check_sys(){
    local checkType=$1
    local value=$2

    local release=''
    local systemPackage=''

    if [[ -f /etc/redhat-release ]]; then
        release="centos"
        systemPackage="yum"
    elif cat /etc/issue | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    elif cat /proc/version | grep -Eqi "debian"; then
        release="debian"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "ubuntu"; then
        release="ubuntu"
        systemPackage="apt"
    elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
        release="centos"
        systemPackage="yum"
    fi

    if [[ ${checkType} == "sysRelease" ]]; then
        if [ "$value" == "$release" ];then
            return 0
        else
            return 1
        fi
    elif [[ ${checkType} == "packageManager" ]]; then
        if [ "$value" == "$systemPackage" ];then
            return 0
        else
            return 1
        fi
    fi
}
#check environment
check_ins(){
    if type $1 >/dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
}

install_app(){
    if check_sys packageManager yum; then
        yum install -y $1
    elif check_sys packageManager apt; then
        apt-get update
        apt-get install -y $1
    fi
}
 #set China timezone
set_timezone(){
    if check_ins ntpdate; then
        install_app ntpdate
    fi

    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    ntpdate asia.pool.ntp.org
    echo -e "Set timezone to GMT+8"
}
check_app(){
    if check_ins $1; then
        echo "$1 has been installed"
    else
        echo "$1 is not installed"
        echo "Install $1..."
        install_app $1
    fi
}

check_docker(){
    if check_ins docker; then
        echo "Docker has been installed"
    else
        echo "Docker is not installed"
        echo "Install Docker..."
        bash <(curl -fsSL https://get.docker.com) --mirror Aliyun
        systemctl start docker
        systemctl enable docker
    fi
}

disable_firewall(){
    if check_sys sysRelease centos; then
        systemctl stop firewalld
        systemctl disable firewalld
    elif check_sys sysRelease ubuntu; then
        ufw disable
    fi
}

pre_install(){
    set_timezone
    check_app curl
    check_app unzip
    check_docker
    disable_firewall
}

gen_docker_compose(){
    cat > $workdir/docker-compose.yml <<EOF
version: '3'

services:
  pmx_sub:
    container_name: pmx_sub
    image: piaomiaoxu/pmx_sub:v2
    restart: always
    volumes:
      - yaoyue:/root/.config/mihomo/
      - ./user.yaml:/root/.config/yaoyue/user.yaml
    network_mode: host
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  metacubexd:
    container_name: metacubexd
    image: ghcr.io/metacubex/metacubexd
    depends_on:
      - mihomo
    restart: always
    ports:
      - '8081:80'
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  mihomo:
    container_name: mihomo
    image: piaomiaoxu/mihomo:v1
    depends_on:
      - pmx_sub
    restart: always
    pid: host
    ipc: host
    network_mode: host
    cap_add:
      - ALL
    volumes:
      - yaoyue:/root/.config/mihomo/
      - /dev/net/tun:/dev/net/tun
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        
volumes:
  yaoyue:
EOF
}




main(){
    cd $workdir
    echo "欢迎使用缥缈墟Linux X86_64 一键安装脚本"
    echo "请使用您在缥缈墟(s.piaomiaoxu.xyz)的邮箱和密码"
    echo "欢迎加入缥缈墟TG群: https://t.me/piaomiaoxu"
    read -p "输入你的邮箱地址:" user_email
    read -p "输入你的密码:" user_password
    echo "email: $user_email" > user.yaml
    echo "password: $user_password" >> user.yaml
    pre_install
    gen_docker_compose
    docker compose -f $workdir/docker-compose.yml up -d
    sleep 10s
    docker restart mihomo
    echo "安装完成"
    echo "请访问 http://IP:8081 登录"
    echo "后端地址请填写: http://IP:9090"
    echo "秘钥留空"
    echo "使用TUN+规则模式最优"
}



main






