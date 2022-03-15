#!/usr/bin/env bash

echo 'Start!'

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.6 2

cd /vagrant

sudo apt-get update
sudo apt-get install tree

# 升级pip，⽬前存在问题，read timed out，看脸，有时候可以，但⼤多时候不⾏
# python -m pip install --upgrade pip
# 换源完美解决
# 安装pip所需依赖
pip install --upgrade setuptools -i https://pypi.tuna.tsinghua.edu.cn/simple
pip install --ignore-installed wrapt -i https://pypi.tuna.tsinghua.edu.cn/simple
# 安装pip最新版
pip install -U pip -i https://pypi.tuna.tsinghua.edu.cn/simple
# 根据 requirements.txt ⾥的记录安装 pip package，确保所有版本之间的兼容性
pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

echo "开始下载mysql"
# 安装配置mysql8
if ! [ -e /vagrant/mysql-apt-config_0.8.15-1_all.deb ]; then
	wget -c https://dev.mysql.com/get/mysql-apt-config_0.8.15-1_all.deb
fi
sudo dpkg -i mysql-apt-config_0.8.15-1_all.deb
#sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
#sudo mysql -h127.0.0.1 -P3306 -uroot -e"UPDATE mysql.user SET password = PASSWORD('yourpassword') WHERE user = 'root'"
sudo apt-get install -y libmysqlclient-dev
if [ ! -f "/usr/bin/pip" ]; then
	sudo apt-get install -y python3-pip
	sudo apt-get install -y python-setuptools
	sudo ln -s /usr/bin/pip3 /usr/bin/pip
else 
	echo "pip3 已安装"
fi

# 设置mysql的root账户的密码为nodjiang
# 创建名为twitter的数据库
sudo mysql -u root << EOF
	ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'nodjiang';
	flush privileges;
	show databases;
	CREATE DATABASE IF NOT EXISTS twitter;
EOF
# fi
# superuser名字
USER="admin"
# superuser密码
PASS="admin"
# superuser邮箱
MAIL="admin@twitter.com"
script="
from django.contrib.auth.models import User;
username = '$USER';
password = '$PASS';
email = '$MAIL';
if not User.objects.filter(username=username).exists():
User.objects.create_superuser(username, email, password);
print('Superuser created.');
else:
print('Superuser creation skipped.');
"
printf "$script" | python manage.py shell

# 如果想直接进⼊/vagrant路径下
# 请输⼊vagrant ssh命令进⼊
# ⼿动输⼊
# 输⼊ls -a
# 输⼊ vi .bashrc
# 在最下⾯，添加cd /vagrant
echo 'All Done!'