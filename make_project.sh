#! /bin/bash

read -p "Project name (Will be created under: ~/Sites ): " project_name

fullpath=$HOME/Sites/$project_name

mkdir -p $fullpath

echo "A project has been created at: $fullpath"

echo "Checking out vagrant setup into project..."
git clone https://github.com/pulpandfiber/vagrant-setup.git $fullpath

echo "Let's configure our Vagrant file!"
echo "Echoing out your hosts file for reference..."

cat /private/etc/hosts

read -p "What internal IP do you want to associate with this vagrant box?: " ipaddy

sed -i.bak "s/192.168.33.10/$ipaddy/g" $fullpath/Vagrantfile
rm $fullpath/Vagrantfile.bak
echo "Updated Vagrantfile to use chosen IP"

echo "$ipaddy	local.$project_name.com phpmyadmin.$project_name.com" >> /private/etc/hosts
echo "Updated hosts file with chosen IP mapped to local.$project_name.com, phpmyadmin.$project_name.com"

mv $fullpath/sites-config/local.PROJECT_NAME.com.conf $fullpath/sites-config/local.$project_name.com.conf
mv $fullpath/sites-config/phpmyadmin.PROJECT_NAME.com.conf $fullpath/sites-config/phpmyadmin.$project_name.com.conf

sed -i.bak "s/PROJECT_NAME/$project_name/g" $fullpath/sites-config/local.$project_name.com.conf
rm $fullpath/sites-config/local.$project_name.com.conf.bak

sed -i.bak "s/PROJECT_NAME/$project_name/g" $fullpath/sites-config/phpmyadmin.$project_name.com.conf
rm $fullpath/sites-config/phpmyadmin.$project_name.com.conf.bak

sed -i.bak "s/PROJECT_NAME/$project_name/g" $fullpath/vagrant_vhosts.sh
rm $fullpath/vagrant_vhosts.sh.bak

vagrant up

echo "Your vagrant box is now running. Access your site at local.$project_name.com"
