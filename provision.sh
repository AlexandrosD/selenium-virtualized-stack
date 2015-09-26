echo "Provisioning starting..."
sudo apt-get update

echo "Installing JDK"
sudo apt-get -y install default-jdk

echo "Installing Selenium Server"
wget -q http://selenium-release.storage.googleapis.com/2.43/selenium-server-standalone-2.43.0.jar
  
echo "Installing LXC"
sudo apt-get -y install lxc

echo "Creating Base LXC container"
sudo lxc-create -n c1 -t ubuntu

echo "Starting container provisioning"
sudo lxc-start -n c1 -d
sleep 10
# Configure lxc container
sudo lxc-attach -n c1 -- sudo -S apt-get -y install xvfb
sudo lxc-attach -n c1 -- sudo -S apt-get update
sudo lxc-attach -n c1 -- sudo -S apt-get -y install firefox
sudo lxc-attach -n c1 -- sudo -S apt-get -y install wget
sudo lxc-attach -n c1 -- wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub
sudo lxc-attach -n c1 -- sudo -S apt-key add linux_signing_key.pub
sudo lxc-attach -n c1 -- sudo -S sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list'
sudo lxc-attach -n c1 -- sudo -S apt-get update
sudo lxc-attach -n c1 -- sudo -S apt-get -y install google-chrome-stable
sudo lxc-attach -n c1 -- sudo -S apt-get -y install default-jdk
sudo lxc-attach -n c1 -- wget -q http://selenium-release.storage.googleapis.com/2.43/selenium-server-standalone-2.43.0.jar

# Create an autostart script for the containers
echo "Xvfb :1 -ac &" >> containerAutostart.sh
echo "export DISPLAY=:1" >> containerAutostart.sh
echo "java -jar /selenium-server-standalone-2.43.0.jar -role node -hub http://10.0.3.1:4444/grid/register &" >> containerAutostart.sh
echo "exit 0" >> containerAutostart.sh
sudo chmod +x containerAutostart.sh
# make containerAutostart.sh autostart
sudo cp containerAutostart.sh /var/lib/lxc/c1/rootfs/etc/rc.local
sudo lxc-stop -n c1

echo "Creating additional LXC containers"
sudo lxc-clone -o c1 -n c2
sudo lxc-clone -o c1 -n c3

## Host autostart script ##
sudo echo "" > /etc/rc.local
# Autostart Selenium server
sudo echo "java -jar /home/vagrant/selenium-server-standalone-2.43.0.jar -role hub &" >> /etc/rc.local
# Make lxc-containers autostart
sudo echo "sudo lxc-start -n c1 -d" >> /etc/rc.local
sudo echo "sudo lxc-start -n c2 -d" >> /etc/rc.local
sudo echo "sudo lxc-start -n c3 -d" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

echo "Provisioning completed!"

echo "Starting Selenium Server as a Hub"
java -jar selenium-server-standalone-2.43.0.jar -role hub &

# Start containers initially
echo "Starting containers"
sudo lxc-start -n c1 -d
sudo lxc-start -n c2 -d
sudo lxc-start -n c3 -d


