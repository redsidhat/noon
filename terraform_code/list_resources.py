#!/usr/bin/env python
import boto3
import json
region_name = 'ap-south-1'
ec2client = boto3.client('ec2', region_name = region_name)
response = ec2client.describe_instances()
print "EC2 instance in region %s" %region_name
print "------------------------------------"
for reservation in response["Reservations"]:
    for instance in reservation["Instances"]:
        print "instanceID :%s" %instance["InstanceId"]
        for interfaces in instance["NetworkInterfaces"]:
            for privip in interfaces["PrivateIpAddresses"]:
                print "privateIP :%s" %privip["PrivateIpAddress"]
        if "PublicIpAddress" in instance:
            print "Public IP :%s" %instance["PublicIpAddress"]
        else:
            print "Public IP :-"
    print "------------------------------------"

rdsclient = boto3.client('rds', region_name = region_name)

response = rdsclient.describe_db_instances()
print "RDS instance in region %s" %region_name
print "------------------------------------"
for dbinstance in response["DBInstances"]:
    print "DB instance identifier :%s" %dbinstance["DBInstanceIdentifier"]
    print "DB instance endpoint :%s" %dbinstance["Endpoint"]["Address"]
    print "------------------------------------"