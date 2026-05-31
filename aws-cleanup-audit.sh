#!/bin/bash

# AWS Cleanup Audit Script
# Checks common billable resources after terraform destroy

REGION=$(aws configure get region)

echo "======================================="
echo " AWS Cleanup Audit - Region: $REGION"
echo "======================================="

echo ""
echo "1. EC2 Instances"
aws ec2 describe-instances \
--filters Name=instance-state-name,Values=pending,running,stopping,stopped \
--query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,PublicIpAddress]' \
--output table

echo ""
echo "2. Load Balancers (ALB/NLB)"
aws elbv2 describe-load-balancers \
--query 'LoadBalancers[*].[LoadBalancerName,Type,State.Code,DNSName]' \
--output table

echo ""
echo "3. Target Groups"
aws elbv2 describe-target-groups \
--query 'TargetGroups[*].[TargetGroupName,Port,Protocol]' \
--output table

echo ""
echo "4. Auto Scaling Groups"
aws autoscaling describe-auto-scaling-groups \
--query 'AutoScalingGroups[*].[AutoScalingGroupName,DesiredCapacity,MinSize,MaxSize]' \
--output table

echo ""
echo "5. EBS Volumes"
aws ec2 describe-volumes \
--query 'Volumes[*].[VolumeId,Size,State,VolumeType]' \
--output table

echo ""
echo "6. Elastic IP Addresses"
aws ec2 describe-addresses \
--query 'Addresses[*].[PublicIp,AllocationId,AssociationId]' \
--output table

echo ""
echo "7. NAT Gateways (High Cost)"
aws ec2 describe-nat-gateways \
--query 'NatGateways[*].[NatGatewayId,State,VpcId]' \
--output table

echo ""
echo "8. Security Groups (Non-default)"
aws ec2 describe-security-groups \
--query 'SecurityGroups[?GroupName!=`default`].[GroupId,GroupName,VpcId]' \
--output table

echo ""
echo "9. Snapshots"
aws ec2 describe-snapshots \
--owner-ids self \
--query 'Snapshots[*].[SnapshotId,StartTime,VolumeSize]' \
--output table

echo ""
echo "10. RDS Instances"
aws rds describe-db-instances \
--query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine]' \
--output table

echo ""
echo "11. S3 Buckets"
aws s3api list-buckets \
--query 'Buckets[*].[Name,CreationDate]' \
--output table

echo ""
echo "======================================="
echo " Audit Complete"
echo " If tables are empty, resources are cleaned."
echo "======================================="
