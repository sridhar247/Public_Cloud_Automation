#!/bin/bash
# Install Docker Compose
# This script sets installs Compose with an alternate TMPDIR. Compose requires exec
# privileges in the /tmp directory, however if /tmp is mounted with `noexec` then
# an error will occur with running `docker-compose`. Rather than changing how /tmp
# is mounted, this script creates a wrapper that sets an alternate `TMPDIR` variable.

COMPOSE_VERSION=1.7.0
TMP_DIR=/data/tmp

mkdir -p $TMP_DIR
chgrp docker $TMP_DIR
chmod g+w $TMP_DIR

# Download release.
curl -L "https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose-real

# Create wrapper.
cat << EOF > /usr/local/bin/docker-compose
#!/bin/bash

TMPDIR="$TMP_DIR" /usr/local/bin/docker-compose-real \$@
EOF

chown root:docker /usr/local/bin/{docker-compose,docker-compose-real}
chmod +x /usr/local/bin/docker-compose-real
chmod +x /usr/local/bin/docker-compose