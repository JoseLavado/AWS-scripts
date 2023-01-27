#!/bin/bash
# This script will extract IPs from access log and add it to AWS Security group of your choosing
#yum -y install cowsay

echo
echo Extracting the IPs from access log and saving as /root/scripts/server1_ip_list.txt
echo
echo "cat /mnt/logs/18379/localhost_access.log | grep "BurNum=37*" | cut -d ',' -f 1 | sort -u > /root/scripts/server1_ip_list.txt"
cat /mnt/logs/18379/localhost_access.log | grep "BurNum=37*" | cut -d ',' -f 1 | sort -u > /root/scripts/server1_ip_list.txt
echo -ne '. \r'
sleep 1
echo -ne '.. \r'
sleep 1
echo -ne '... \r'
sleep 1
echo -ne '.... \r'
echo -ne '\n'
echo done.
echo
echo adding IPs to Security group...
echo

cd /root/scripts/
file="server1_ip_list.txt"

while read -r line; do
#   echo -e "$line\n"

groupid="sg-0eda6522984404af9"

aws ec2 authorize-security-group-ingress --group-id ${groupid} --protocol tcp --port 23 --cidr ${line}/24
echo aws ec2 authorize-security-group-ingress --group-id ${groupid} --protocol tcp --port 23 --cidr ${line}/24

sleep 1

done <$file
echo
echo done.
echo
cowsay "done"
#echo