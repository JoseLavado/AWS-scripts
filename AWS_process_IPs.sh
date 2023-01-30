# test upload server1_ip_list_sunday.txt "aws s3 cp server1_ip_list_sunday.txt s3://ip-list-bucket/server1_ip_list_sunday.txt"
# server1_ip_list_sunday.txt content:
1.1.1.1
2.2.2.2
3.3.3.3
4.4.4.4
************************************************************************************************************************************
#!/bin/bash
# script name=weekly_ec2_upload.sh
# EC2 instances will weekly (sunday 1am) upload their latest IP file of the day to S3 bucket 
# add to the weekly cron job on EC2 instances

bucket_name="ip-list-bucket"
server_name=$HOSTNAME
bucket_file=${server_name}.txt
cp /root/scripts/server1_ip_list.txt /root/scripts/${bucket_file}
aws s3 cp /root/scripts/${bucket_file} s3://${bucket_name}/${bucket_file}

************************************************************************************************************************************
#!/bin/bash
# script name=update_sg.sh
# download the weekly file from EC2 and update SG after purge 

bucket_name="ip-list-bucket"
bucket_file="server1_ip_list_sunday.txt"
file1="server1_ip_list_sunday.txt"
groupid="sg-0eda6522984404af9"

aws s3 cp s3://${bucket_name}/${bucket_file} ./server1_ip_list_sunday.txt

while read -r line; do
#aws ec2 authorize-security-group-ingress --group-id ${groupid} --protocol tcp --port 23 --cidr ${line}/32
aws ec2 authorize-security-group-ingress --group-id ${groupid} --protocol tcp --port 23 --cidr ${line}/32
sleep 1
done <$file1

************************************************************************************************************************************
#!/bin/bash
# script name=erase_rules_sg.sh
# get contents of SG and dump into a file to extract the IPs to be deleted, will leave SG empty

#!/bin/bash
groupid="sg-0eda6522984404af9"
aws ec2 describe-security-group-rules --filter Name="group-id",Values="sg-0eda6522984404af9" > raw_ip_list.txt
cat raw_ip_list.txt | grep "Cidr" | cut -d '"' -f 4 | grep -v 0.0.0.0 > ip_list.txt
ip_file="ip_list.txt"
while read -r line; do
echo aws ec2 revoke-security-group-ingress --group-id ${groupid} --protocol tcp --port 23 --cidr ${line}
aws ec2 revoke-security-group-ingress --group-id ${groupid} --protocol tcp --port 23 --cidr ${line}
done <$ip_file

