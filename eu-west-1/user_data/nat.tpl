#!/bin/bash
sysctl -w net.ipv4.ip_forward=1
/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
yum install -y iptables-services jq
service iptables save

amazon-linux-extras install -y nginx1

export AWS_DEFAULT_REGION=eu-west-1
aws secretsmanager get-secret-value \
  --secret-id arn:aws:secretsmanager:eu-west-1:055237546114:secret:server.pem-1oLgLZ \
  | jq -r .SecretString \
  > /etc/nginx/server.pem

aws secretsmanager get-secret-value \
  --secret-id arn:aws:secretsmanager:eu-west-1:055237546114:secret:server.key-HyXG1o \
  | jq -r .SecretString \
  > /etc/nginx/server.key

aws ssm get-parameter --name nginx.conf \
  | jq -r .Parameter.Value \
  > /etc/nginx/nginx.conf

systemctl enable --now nginx
