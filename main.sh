#!/bin/bash
color='\e[1;33m'
endColor='\e[0m'

# Hello World Program in Bash Shell
echo -e "${color}Hello World!, Bash Script to configure AeroD server.${endColor}"

# Add "devuser" to Machine
bash ./adduser.sh

# Install various tools
apt-get install fail2ban -y


# Executing iptables script
bash ./iptables.sh

echo -e "${color}Do you wish to install/configure swap? Please enter 1 or 2: ${endColor}"
# read -p "Input Selection:" yn
select yn in "Yes" "No"; do
    case $yn in
        Yes )
			SWAPRESULT=$(swapon -s | grep -c "/swapfile")
			if [ $SWAPRESULT -eq 0 ] 
				then
					echo -e "${color}Swap file not found, Creating swap....${endColor}"
					sh ./swap.sh;
			else
				echo -e "${color}Swap already found, skipping creation....${endColor}"
			fi
			break;;
        No ) break;;
    esac
done

echo -e "${color}Installing packages...${endColor}"
bash ./packages.sh

echo -e "${color}Reconfigure mySQL....${endColor}"
sudo dpkg-reconfigure mysql-server-5.5

# Resetting nginx and apache config
echo -e "${color}Resetting Nginx and Apache2 sites-available/enabled${endColor}"
sudo rm -r /etc/nginx/sites-available/*
sudo rm -r /etc/apache2/sites-available/*
sudo rm -r /etc/nginx/sites-enabled/*
sudo rm -r /etc/apache2/sites-enabled/*

# Jenkins import
# for i in `ls jobs`; do echo -e "${color}jobs/$i/config.xml";done > config.tota${endColor}r
# tar zcf ~/jenkins_config-`date +"%Y%m%d%H%M%S"`.tar.gz *.xml userContent/ plugins/ -T config.totar
echo -e "${color}Extracting Jenkins config to .jenkins${endColor}"
su -c "mkdir /home/devuser/.jenkins" -s /bin/bash devuser
sudo tar zxf jenkins/jenkins_config.tar.gz -C /home/devuser/.jenkins/
sudo chown -R devuser:devuser /home/devuser/.jenkins
# setting Jenkins security to false.
echo -e "${color}Disabling Jenkins security. Remember to add security during initial boot.${endColor}"
sudo sed -i "s/<useSecurity>true/<useSecurity>false/g" /home/devuser/.jenkins/config.xml

# Starting Jenkins
echo -e "${color}Starting Jenkins....${endColor}"
su -c "nohup java -jar /home/devuser/jenkins.war --httpPort=8881 > /home/devuser/jenkinswar.log 2>&1 &" -s /bin/sh devuser
# nohup java -jar /home/devuser/jenkins.war --httpPort=8881 > /home/devuser/jenkinswar.log 2>&1

echo -e "${color}Configuring Jenkins....${endColor}"
sudo cp conf/nginx_vhostjenkins /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/nginx_vhostjenkins /etc/nginx/sites-enabled/ | true

echo -e "${color}Printing nginx config...${endColor}"
sudo nginx -t
sudo service nginx restart

echo -e "${color}Configuring/building projects directory, so that you can start building your projects${endColor}"
su -c "mkdir /home/devuser/projects" -s /bin/bash devuser
echo -e "${color}Configuring nginx and apache2 sites-available for projects${endColor}"
echo -e "${color}Copying error file to /usr/share/nginx/html${endColor}"
sudo cp conf/*.html /usr/share/nginx/html
echo -e "${color}Copying nginx_vhost to nginx conf${endColor}"
sudo cp conf/nginx_vhost /etc/nginx/sites-available/
echo -e "${color}Enabling nginx_vhost${endColor}"
sudo ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/ | true
sudo nginx -t
sudo service nginx restart
echo -e "${color}copy apache2.conf and ports.conf to apache2${endColor}"
sudo cp conf/{apache2.conf,ports.conf} /etc/apache2/
echo -e "${color}copy aerod apache configs to sites-available${endColor}"
sudo cp conf/{aerod-backend-account.conf,aerod-backend-admin.conf,aerod-backend-customer.conf,aerod-backend-payment.conf,aerodcrm.conf,suitecrm-7.1.7-max.conf} /etc/apache2/sites-available/
echo -e "${color}enabling apache2 aerod sites${endColor}"
sudo a2ensite aerod-backend-account.conf
sudo a2ensite aerod-backend-admin.conf
sudo a2ensite aerod-backend-customer.conf
sudo a2ensite aerod-backend-payment.conf
sudo a2ensite aerodcrm.conf
sudo a2ensite aerod-backend-migrated.conf
#sudo a2ensite suitecrm-7.1.7-max.conf
sudo service apache2 restart

#Installing php
echo -e "${color}Installing Php ${endColor}"
sudo apt-get install -y php5 php5-cli php5-common php5-dev php5-mysql php5-curl php5-gd php-pear php5-imap php5-mcrypt php5-xmlrpc php5-xsl
sudo cp conf/php.ini /etc/php5/apache/

echo -e "${color}enabling supervisord for aerod${endColor}"
sudo cp conf/laravel-worker.conf /etc/supervisor/conf.d/
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start laravel-worker:*

# echo -e "${color}cloning & configuring suitecrm....${endColor}"
# git clone https://bitbucket.org/aerodteam/aerod-suitecrm.git /home/devuser/projects/suitecrm-7.1.7-max
# sudo chown -R  www-data:www-data /home/devuser/projects/suitecrm-7.1.7-max

# Setting up JAVA services
# echo -e "${color}Setting up JAVA services....${endColor}"
# sudo cp conf/{emailservice,gatewayservice,monitoringservice,socialservice,triggerservice} /etc/init.d
# sudo chmod +x /etc/init.d/{emailservice,gatewayservice,monitoringservice,socialservice,triggerservice}

# Start service but we cant since we are still pending jenkins to be build by user
# sudo service emailservice start

# Creating aerod tables and importing data.
echo -e "${color}Importing DBs....${endColor}"
echo -e "${color}Please enter mysql root password....${endColor}"
echo "CREATE DATABASE aerod" | mysql -uroot -p
echo "flush privileges" | mysql -uroot -p
echo -e "${color}creating tables....${endColor}"
mysql -u root -p aerod < conf/ddl.sql
echo -e "${color}importing country and states....${endColor}"
mysql -u root -p aerod < conf/country.sql
mysql -u root -p aerod < conf/state_usa.sql
mysql -u root -p aerod < conf/state_canada.sql

echo "installation completed successfully"

