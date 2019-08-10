#!/bin/bash
apt update
apt install apache2 php mysql-server -y
systemctl start apache2.service
systemctl enable apache2.service
systemctl enable mysql.service
systemctl restart apache2.service
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xvzf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -r wordpress
rm latest.tar.gz
echo "<html><h1>Healthy</h1></html>" > healthcheck.html
apt install awscli -y
apt upgrade -y
