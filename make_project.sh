#! /bin/bash

read -p "Project name (Will be created under: ~/Sites ): " project_name_initial

project_name=${project_name_initial,,}

fullpath=$HOME/Sites/$project_name

mkdir -p $fullpath

echo "A project folder has been created at: $fullpath"

echo "Checking out vagrant setup into project..."
git clone https://github.com/pulpandfiber/vagrant-setup.git $fullpath

mkdir -p $fullpath/htdocs

read -p "Would you like to setup a new wordpress project (We will also setup the database)? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
cd $fullpath/htdocs
wp core download
cd $fullpath/htdocs/wp-content/themes
mkdir -p $fullpath/htdocs/wp-content/themes/fs
cd $fullpath/htdocs/wp-content/themes/fs
git clone https://github.com/pulpandfiber/wp-theme-from-scratch.git .
mv from_scratch ../
mv from_scratch_child ../
mv grunt ../../../
cd ../
rm -rf fs

mv $fullpath/htdocs/wp-config-sample.php $fullpath/htdocs/wp-config.php

sed -i.bak "s/database_name_here/$project_name/g" $fullpath/htdocs/wp-config.php
rm $fullpath/htdocs/wp-config.php.bak

sed -i.bak "s/username_here/$project_name/g" $fullpath/htdocs/wp-config.php
rm $fullpath/htdocs/wp-config.php.bak

sed -i.bak "s/password_here/$project_name/g" $fullpath/htdocs/wp-config.php
rm $fullpath/htdocs/wp-config.php.bak

echo "Updated Vagrantfile to use chosen IP."

echo "Updated wp-config.php with db info."

else
  exit 0
fi

cd $fullpath

wget --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/4.6.4/phpMyAdmin-4.6.4-all-languages.zip
unzip ./phpMyAdmin-4.6.4-all-languages.zip
mv phpMyAdmin-4.6.4-all-languages/ phpmyadmin/
rm phpMyAdmin-4.6.4-all-languages.zip

echo "Let's configure our Vagrant file!"
echo "Echoing out your hosts file for reference..."

cat /private/etc/hosts

read -p "What internal IP do you want to associate with this vagrant box?: " ipaddy

sed -i.bak "s/192.168.33.10/$ipaddy/g" $fullpath/Vagrantfile
rm $fullpath/Vagrantfile.bak
echo "Updated Vagrantfile to use chosen IP"

echo "$ipaddy	local.$project_name.com phpmyadmin.$project_name.com" >> /private/etc/hosts
echo "Updated hosts file with chosen IP mapped to local.$project_name.com, phpmyadmin.$project_name.com"

mv $fullpath/vagrant-sites-config/local.PROJECT_NAME.com.conf $fullpath/vagrant-sites-config/local.$project_name.com.conf
mv $fullpath/vagrant-sites-config/phpmyadmin.PROJECT_NAME.com.conf $fullpath/vagrant-sites-config/phpmyadmin.$project_name.com.conf

sed -i.bak "s/PROJECT_NAME/$project_name/g" $fullpath/vagrant-sites-config/local.$project_name.com.conf
rm $fullpath/vagrant-sites-config/local.$project_name.com.conf.bak

sed -i.bak "s/PROJECT_NAME/$project_name/g" $fullpath/vagrant-sites-config/phpmyadmin.$project_name.com.conf
rm $fullpath/vagrant-sites-config/phpmyadmin.$project_name.com.conf.bak

sed -i.bak "s/PROJECT_NAME/$project_name/g" $fullpath/vagrant-setup-script/vagrant_vhosts.sh
rm $fullpath/vagrant-setup-script/vagrant_vhosts.sh.bak

vagrant up

echo "Your vagrant box is now running. Access your site at local.$project_name.com"
