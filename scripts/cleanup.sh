#!/bin/bash

# Wait for instance status or any other pre-cleanup actions
aws --profile $PROFILE ec2 wait instance-status-ok --region $REGION_WORKER --instance-ids $INSTANCE_ID

# Execute the cleanup command
java -jar /home/ec2-user/jenkins-cli.jar -auth @/home/ec2-user/jenkins_auth -s http://${MASTER_IP}:8080/ delete-node ${WORKER_IP}
