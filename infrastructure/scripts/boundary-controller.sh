#!/bin/bash

yum install -y yum-utils shadow-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install boundary

# Create the Boundary configuration directory
mkdir -p /etc/boundary

cat > /etc/boundary/tls/key.pem <<- EOF
${SERVER_KEY}
EOF

cat > /etc/boundary/tls/cert.pem <<- EOF
${SERVER_CERT}
EOF

# Adding a system user and group
useradd --system --user-group boundary || true

# Changing ownership of directories and files
chown boundary:boundary -R /etc/boundary
chown boundary:boundary /usr/bin/boundary