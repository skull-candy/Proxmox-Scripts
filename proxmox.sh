#!/bin/bash
echo "Hello, $(whoami)!"
echo "We Are Going To Install SNMP Server and Enable Proxmox Stats Collection For LibreNMS !"
echo 'Shall We Begin ? Type "y" to Confirm !'
read "age"
if [ $age == "y" ]
then
echo ' Ok Here We Go ...'
echo ' '
apt update
echo ' '
echo ' Installing SNMPD...'
echo ' '
apt install snmpd -y
echo ' '
echo ' Configuring SNMPD To Connect To VNS NMS'
echo ' '
mv /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.ori

cat <<EOT >> /etc/snmp/snmpd.conf
agentAddress udp:161,udp6:[::1]:161
view   systemonly  included   .1.3.6.1.2.1.1
view   systemonly  included   .1.3.6.1.2.1.25.1
 rocommunity public  default    -V systemonly
 rocommunity6 public  default   -V systemonly
rouser   authOnlyUser
sysLocation    Sitting on the Dock of the Bay
sysContact     Me <me@example.org>
sysServices    72
proc  mountd
proc  ntalkd    4
proc  sendmail 10 1
disk       /     10000
disk       /var  5%
includeAllDisks  10%
load   12 10 5
 trapsink     localhost public
iquerySecName   internalUser
rouser          internalUser
defaultMonitors          yes
linkUpDownNotifications  yes
master          agentx

EOT
echo ' '
echo ' DONE , Restarting SNMPD'
echo ' '
systemctl restart snmpd 
echo ' '
echo ' Downloading And Enabling PROXMOX Stats Deamon...'
echo ' '
apt install git -y
cd /opt/
git clone https://github.com/librenms/librenms-agent.git
cd librenms-agent
cp check_mk_agent /usr/bin/check_mk_agent
chmod +x /usr/bin/check_mk_agent
cp check_mk@.service check_mk.socket /etc/systemd/system
mkdir -p /usr/lib/check_mk_agent/plugins /usr/lib/check_mk_agent/local
cd agent-local/
cp proxmox /usr/lib/check_mk_agent/local
chmod +x /usr/lib/check_mk_agent/local/proxmox
systemctl enable check_mk.socket && systemctl start check_mk.socket
echo ' '
echo ' '
echo ' '
echo 'Done , Thank You , Please Dont Forget To Enable Proxmox Under Applications in The Device Settings in LibreNMS !'
echo ' '
else
echo ' '
    echo 'Ok As You Wish , Cancelling !'
    echo ' '
fi
