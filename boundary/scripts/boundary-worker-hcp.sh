#!/bin/bash

# Install necessary packages
yum install -y yum-utils shadow-utils jq
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install boundary-enterprise

# Get token for fetching metadata and local ipv4
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
LOCAL_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/local-ipv4")
PUBLIC_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/public-ipv4")

mkdir -p /etc/boundary.d
mkdir -p /etc/boundary.d/worker

# Boundary worker configuration
cat > /etc/boundary.d/boundary.hcl <<- EOF
disable_mlock = true

hcp_boundary_cluster_id = "${HCP_BOUNDARY_CLUSTER_ID}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "$${PUBLIC_IPV4}"

  auth_storage_path = "/etc/boundary.d/worker"
  
  recording_storage_path = "/var/log/boundary"

  tags {
    type = ["hcp"]
    purpose = ["ec2"]
  }
}
EOF

# Adding a system user and group
useradd --system --user-group boundary || true

# Changing ownership of directories and files
chown boundary:boundary -R /etc/boundary.d
chown boundary:boundary /usr/bin/boundary
chown boundary:boundary /var/log/boundary

mkfs -t xfs /dev/nvme1n1
mkdir -p /var/log/boundary
mount /dev/nvme1n1 /var/log/boundary

chgrp boundary /var/log/boundary
chmod g+rwx /var/log/boundary