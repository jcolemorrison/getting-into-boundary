#!/bin/bash

# Install necessary packages
yum install -y yum-utils shadow-utils jq
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install boundary

# Get token for fetching metadata and local ipv4
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
LOCAL_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://169.254.169.254/latest/meta-data/local-ipv4")

# URL-encode the password
ENCODED_DB_PASSWORD=$(echo -n "${DB_PASSWORD}" | jq -sRr @uri)

# Create the Boundary configuration directory and TLS subdirectory
mkdir -p /etc/boundary.d/tls
mkdir -p /var/log/boundary

# Write the server key and certificate to the appropriate files
cat > /etc/boundary.d/tls/key.pem <<- EOF
${SERVER_KEY}
EOF

cat > /etc/boundary.d/tls/cert.pem <<- EOF
${SERVER_CERT}
EOF

cat > /etc/boundary.d/boundary.env <<- EOF
BOUNDARY_DB_CONNECTION=postgresql://${DB_USERNAME}:$${ENCODED_DB_PASSWORD}@${DB_ENDPOINT}/${DB_NAME}
EOF

cat > /etc/boundary.d/boundary.hcl <<- EOF
# # Note that this is an example config file and is not intended to be functional as-is.
# # Full configuration options can be found at https://www.boundaryproject.io/docs/configuration/controller

# Disable memory lock: https://www.man7.org/linux/man-pages/man2/mlock.2.html
disable_mlock = true

# Controller configuration block
controller {
  # This name attr must be unique across all controller instances if running in HA mode
  name = "boundary-controller-${INDEX}"
  description = "A controller for a demo!"

  # Database URL for postgres. This can be a direct "postgres://"
  # URL, or it can be "file://" to read the contents of a file to
  # supply the url, or "env://" to name an environment variable
  # that contains the URL.
  database {
      url = "env://BOUNDARY_DB_CONNECTION"
  }
}

# # API listener configuration block
listener "tcp" {
  # Should be the address of the NIC that the controller server will be reached on
  address = "$${LOCAL_IPV4}:9200"
  # The purpose of this listener block
  purpose = "api"

  tls_disable = false
  tls_cert_file = "/etc/boundary.d/tls/cert.pem"
  tls_key_file = "/etc/boundary.d/tls/key.pem"

  # Uncomment to enable CORS for the Admin UI. Be sure to set the allowed origin(s)
  # to appropriate values.
  #cors_enabled = true
  #cors_allowed_origins = ["https://yourcorp.yourdomain.com", "serve://boundary"]
}

# Data-plane listener configuration block (used for worker coordination)
listener "tcp" {
  # Should be the IP of the NIC that the worker will connect on
  address = "$${LOCAL_IPV4}:9201"
  # The purpose of this listener
  purpose = "cluster"
}

# For health checks for load balancer
listener "tcp" {
  # Should be the IP of the NIC that the worker will connect on
  address = "$${LOCAL_IPV4}:9203"
  # The purpose of this listener
  purpose = "ops"

  tls_disable = false
  tls_cert_file = "/etc/boundary.d/tls/cert.pem"
  tls_key_file = "/etc/boundary.d/tls/key.pem"
}

# Root KMS configuration block: this is the root key for Boundary
# Use a production KMS such as AWS KMS in production installs
kms "awskms" {
  purpose = "root"
  region = "us-east-1"
  kms_key_id = "${KMS_ROOT_KEY_ID}"
}

# Worker authorization KMS
# Use a production KMS such as AWS KMS for production installs
# This key is the same key used in the worker configuration
kms "awskms" {
  purpose = "worker-auth"
  region = "us-east-1"
  kms_key_id = "${KMS_WORKER_AUTH_KEY_ID}"
}

# Recovery KMS block: configures the recovery key for Boundary
# Use a production KMS such as AWS KMS for production installs
kms "awskms" {
  purpose = "recovery"
  region = "us-east-1"
  kms_key_id = "${KMS_RECOVERY_KEY_ID}"
}

events {
  observations_enabled = true
  sysevents_enabled = true
  telemetry_enabled = true
  audit_enabled = true

  sink {
    name = "obs-sink"
    description = "Observations sent to a file"
    event_types = ["observation"]
    format = "cloudevents-text"
    file {
      path = "/var/log/boundary"
      file_name = "obs.log"
    }
  }
  sink {
    name = "audit-sink"
    description = "Audit sent to a file"
    event_types = ["audit"]
    format = "cloudevents-text"
    file {
      path = "/var/log/boundary"
      file_name = "audit.log"
    }
  }
  sink {
    name = "sysevents-sink"
    description = "Sysevents sent to a file"
    event_types = ["system","error"]
    format = "cloudevents-text"
    file {
      path = "/var/log/boundary"
      file_name = "sysevents.log"
    }
  }
  sink {
    name = "telemetry-sink"
    description = "Telemetry sent to a file"
    event_types = ["telemetry", "observation"]
    format = "cloudevents-text"
    file {
      path = "/var/log/boundary"
      file_name = "telemetry.log"
    }
  }
}
EOF

# Adding a system user and group
useradd --system --user-group boundary || true

# Changing ownership of directories and files
chown boundary:boundary -R /etc/boundary.d
chown boundary:boundary /usr/bin/boundary
chown boundary:boundary /var/log/boundary
chmod 755 /var/log/boundary

touch /var/log/boundary/obs.log
touch /var/log/boundary/sysevents.log
chown boundary:boundary /var/log/boundary/*.logs

export BOUNDARY_DB_CONNECTION="postgresql://${DB_USERNAME}:$${ENCODED_DB_PASSWORD}@${DB_ENDPOINT}/${DB_NAME}"

# Run the command and capture the exit code
boundary database init -config /etc/boundary.d/boundary.hcl
boundary_db_init=$?

# Check if the exit code is 0 or 2
if [ $boundary_db_init -eq 0 ] || [ $boundary_db_init -eq 2 ]; then
  echo "Command succeeded with exit code $boundary_db_init"
else
  echo "Command failed with exit code $boundary_db_init"
  exit $boundary_db_init
fi

# Run the command and capture the exit code
boundary database migrate -config /etc/boundary.d/boundary.hcl
boundary_db_migrate=$?

# Check if the exit code is 0 or 2
if [ $boundary_db_migrate -eq 0 ] || [ $boundary_db_migrate -eq 2 ]; then
  echo "Command succeeded with exit code $boundary_db_migrate"
else
  echo "Command failed with exit code $boundary_db_migrate"
  exit $boundary_db_migrate
fi

# Reload systemd manager configuration
systemctl daemon-reload

# Enable and start the Boundary service
systemctl enable boundary
systemctl start boundary