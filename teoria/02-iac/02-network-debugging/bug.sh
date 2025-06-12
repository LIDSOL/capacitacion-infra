# Script that introduces a bug in the network configuration
# Note: This script is intended for educational purposes only.
#!/bin/bash

# Install the systemd bug.service
wget -q https://raw.githubusercontent.com/LIDSOL/capacitacion-infra/refs/heads/main/teoria/02-iac/02-network-debugging/bug.service -O /etc/systemd/system/bug.service
# Enable the service to start on boot
systemctl enable bug.service

# Start the service
systemctl start bug.service

# Print a message indicating that the bug has been introduced
echo "Bug introduced: Network configuration has been modified. Check the bug.service for details."
