#!/bin/bash -oe
function init_var()
{
    GIT_USERNAME='linliang'
    GIT_EMAIL="linliang@gmail.com"
}


# 因为要修改源等和安装软件，需要root权限，所以先获得ROOT权限
function is_root()
{
    ROOT_UID=0

    if [ $UID -ne $ROOT_UID ];then
        echo "This script need ROOT right, Please run as root."
        exit
    fi
}


# 使用163的更新源，同时加上JDK的源
function update_apt_source()
{
    UBUNTU_CODENAME=$(lsb_release  -c | awk '{print $NF}')
    JDK_URL="deb http://us.archive.ubuntu.com/ubuntu/ hardy multiverse"
    APT_FILE="/etc/apt/sources.list"
    mv $APT_FILE $APT_FILE.bak

    cat >> $APT_FILE << EOF
deb http://mirrors.163.com/ubuntu/ $UBUNTU_CODENAME main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ $UBUNTU_CODENAME-security main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ $UBUNTU_CODENAME-updates main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ $UBUNTU_CODENAME-proposed main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ $UBUNTU_CODENAME-backports main restricted universe multiverse
$JDK_URL
EOF
    # 添加nvidia显卡驱动地址
    sudo add-apt-repository ppa:ubuntu-x-swat/x-updates
    apt-get update && apt-get -y upgrade
}


# 安装常用软件
function install_software()
{
    apt-get install -y vim vim-gnome git-core chromium-browser ipython tree sun-java6-jdk \
        flashplugin-installer gnome-shell python-pip virtualbox nvidia-current \
        nvidia-current-modaliases nvidia-settings vlc stardict etckeeper

    pip install markdown
}


# 不需要ROOT权限
function config_software()
{
    # 配置Git信息
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global color.ui auto

    # 配置vim
    ssh -o StrictHostKeyChecking=no git@github.com
    git clone git://github.com/crazygit/vimconf.git ~/.vim
    ln -s ~/.vim/vimrc ~/.vimrc
    cd ~/.vim
    git submodule init
    git submodule update

    # 给man pages添加颜色
    BASHRC_FILE="$HOME/.bashrc"
    cat >> $BASHRC_FILE <<'EOF'

#color man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

EOF
    # 让命令行支持vi模式
    echo "set -o vi" >> $BASHRC_FILE
    # 给命令行提示符号颜色
    sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/' $BASHRC_FILE
    # 增加记录HISTORY的条数
    sed -i 's/HISTSIZE=1000/HISTSIZE=10000/' $BASHRC_FILE
    sed -i 's/HISTFILESIZE=2000/HISTFILESIZE=20000/' $BASHRC_FILE
}
