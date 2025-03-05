#!/bin/bash

# Install necessary packages
yum install -y yum-utils shadow-utils jq
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install boundary

# Get token for fetching metadata and local ipv4
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
LOCAL_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/local-ipv4")
PUBLIC_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/public-ipv4")

mkdir -p /etc/boundary.d

# Boundary worker configuration
cat > /etc/boundary.d/boundary.hcl <<- EOF
disable_mlock = true

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "$${PUBLIC_IPV4}"

  initial_upstreams = ${CONTROLLER_ADDRESSES}

  tags {
    type = ["ctrl-led"]
    purpose = ["ec2", "eks"]
  }

  auth_storage_path = "/etc/boundary.d/ctrl-worker-${WORKER_ID}"

  controller_generated_activation_token = "${CONTROLLER_GENERATED_ACTIVATION_TOKEN}"
}
EOF

# Adding a system user and group
useradd --system --user-group boundary || true

# Ensure the directory exists and has the correct permissions
mkdir -p "/etc/boundary.d/ctrl-worker-${WORKER_ID}/nodecreds"
chown -R boundary:boundary "/etc/boundary.d/ctrl-worker-${WORKER_ID}"
chmod -R 755 "/etc/boundary.d"

# Changing ownership of directories and files
chown boundary:boundary -R /etc/boundary.d
chown boundary:boundary /usr/bin/boundary

# Reload systemd manager configuration
systemctl daemon-reload

# Enable and start the Boundary service
systemctl enable boundary
systemctl start boundary