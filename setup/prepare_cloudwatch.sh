#!/usr/bin/env bash
source init.sh

# Setup cloudwatch file monitoring on EC2 instances using cloudwatch logs
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/AgentReference.html

REMOTE=$(cat <<EOF
echo Creating CloudWatch config in /root/awslogs.conf
echo """
[general]
state_file = /var/awslogs/state/agent-state
use_gzip_http_content_encoding = true

[syslog]
datetime_format = %Y-%m-%d %H:%M:%S
file = /var/log/syslog
buffer_duration = 5000
log_stream_name = {instance_id}-{ip_address}-syslog
initial_position = start_of_file
log_group_name = $TAG-futuswarm-syslog
""" > /root/awslogs.conf

echo Downloading cloudwatch logs setup agent
cd /root
wget https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py

echo Running non-interactive awslogs-agent-setup
python ./awslogs-agent-setup.py --region=$AWS_REGION --non-interactive --configfile=/root/awslogs.conf

EOF
)
run_sudo $HOST "$REMOTE"
