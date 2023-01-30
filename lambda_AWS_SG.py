import json
import boto3
#The below declarations must be placed before handler function
s3_client = boto3.client('s3')
ec2_client = boto3.client('ec2')
  
#This is the lambda default handler
def lambda_handler(event, context):
  print("START***************************************************************************")
  #Use boto to download bucket file that has the IPs
  s3_bucket = "ip-list-bucket"
  bucket_key = "server1_ip_list.txt"
  data = s3_client.get_object(Bucket=s3_bucket, Key=bucket_key)
  filecontent = data["Body"].read()
  list1=(filecontent.decode())
  print("list here:")
  list2=list1.split("\n")
  print(list2)
  size_list=len(list2)
  print(size_list)
  
  #Use the dummy ip vars to test adding IPs into SG via the loop below
  ip2="6.6.6.6/32"
  ip3="7.7.7.7/32"
  ip_list=[ip2,ip3]
  print(ip_list)

  for i in ip_list:
    #The try will catch already added IPs and prevent the lambda fn from crashing 
    try: 
      ec2_client.authorize_security_group_ingress(GroupId="sg-0eda6522984404af9",IpPermissions=[{'IpProtocol': 'tcp','FromPort': 80,'ToPort': 80,'IpRanges': [{'CidrIp': i}]}])
    except:
      print("already added")
    
  #ec2_client.authorize_security_group_ingress(GroupId="sg-0eda6522984404af9",IpPermissions=[{'IpProtocol': 'tcp','FromPort': 80,'ToPort': 80,'IpRanges': [{'CidrIp': ip3}]}])
  print("END******************************************************************************")
  
  
  
  