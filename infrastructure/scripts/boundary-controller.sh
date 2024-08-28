#!/bin/bash

yum install -y yum-utils shadow-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install boundary

# Create the Boundary configuration directory
mkdir -p /etc/boundary

cat > /etc/boundary/tls/ca.crt <<- EOF
${SERVER_CA}
EOF

cat > /etc/boundary/tls/tls.crt <<- EOF
${SERVER_PUBLIC_KEY}
EOF

cat > /etc/boundary/tls/tls.key <<- EOF
${SERVER_PRIVATE_KEY}
EOF

# Adding a system user and group
useradd --system --user-group boundary || true

# Changing ownership of directories and files
chown boundary:boundary -R /etc/boundary
chown boundary:boundary /usr/bin/boundary