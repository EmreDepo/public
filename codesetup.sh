#!/bin/bash

# Sudo kurulumunu yap
apt-get install sudo -y

# Sistem güncellemelerini yap
sudo apt update && sudo apt upgrade -y

# Yeniden başlatma gerekiyorsa, sistemi yeniden başlat
[ -f /var/run/reboot-required ] && sudo reboot -f

# Gerekli araçları yükle
sudo apt install -y htop screen tcpdump net-tools dnsutils curl byobu sysstat ncdu iotop gnupg2 ranger git composer

# Zaman dilimini ayarla
sudo timedatectl set-timezone Europe/Istanbul

# Apache ve PHP kurulumunu yap
sudo apt install apache2 php libapache2-mod-php php-mysql -y

# MariaDB kurulumunu yap
sudo apt install mariadb-server mariadb-client -y

# MariaDB'nin güvenli kurulumunu yap
sudo mariadb-secure-installation

# MariaDB servisini başlat ve otomatik başlatma ayarını yap
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Apache'nin dizin yapılandırmasını değiştir
sudo nano /etc/apache2/mods-enabled/dir.conf

# İndex dosya sırasını değiştir
# DirectoryIndex index.php index.cgi index.pl index.html index.xhtml index.htm

# Apache servisini yeniden başlat
sudo service apache2 restart

# VirtualHost yapılandırmasını düzenle
sudo nano /etc/apache2/sites-available/crm.telpass.com.tr.conf

# Aşağıdaki yapılandırmayı yapıştır
# <VirtualHost *:80>
#     ServerName crm.telpass.com.tr
#     DocumentRoot /var/www/html/crm
#
#     <Directory /var/www/html/crm>
#         Options Indexes FollowSymLinks MultiViews
#         AllowOverride All
#         Order allow,deny
#         allow from all
#     </Directory>
#
#     ErrorLog ${APACHE_LOG_DIR}/crm.telpass.com.tr_error.log
#     CustomLog ${APACHE_LOG_DIR}/crm.telpass.com.tr_access.log combined
# </VirtualHost>

# VirtualHost yapılandırmasını etkinleştir
sudo a2ensite crm.telpass.com.tr.conf

# Apache servisini yeniden yükle
sudo systemctl reload apache2

# Gerekli Apache modüllerini etkinleştir
sudo a2enmod rewrite
sudo a2enmod ssl

# Apache servisini yeniden başlat
sudo systemctl restart apache2

# CRM dizini oluştur
mkdir /var/www/html/crm

# CodeIgniter 4 projesini oluştur
cd /var/www/html
composer create-project codeigniter4/appstarter crm

# CRM dizininin sahipliğini www-data kullanıcısına ver
sudo chown -R www-data:www-data crm

# CRM dizinindeki dosya izinlerini ayarla
sudo chmod -R 755 crm/writable

# CRM sistemator klasörü için dosya izinlerini ayarla
sudo chown -R www-data:www-data /var/www/html/crm/sistemator/writable/cache/
sudo chmod -R 775 /var/www/html/crm/sistemator/writable/cache/
ls -la /var/www/html/crm/sistemator/writable/cache/  # Dosya izinlerini kontrol etmek için

sudo chown -R www-data:www-data /var/www/html/crm/sistemator/writable/session/
sudo chmod -R 770 /var/www/html/crm/sistemator/writable/session/
sudo mkdir -p /var/www/html/crm/sistemator/writable/session/

# Apache servisini yeniden başlat
sudo systemctl restart apache2
