#!/bin/bash
sudo bash -c 'cat << "EOF" > /usr/local/bin/ec2-inactivity-shutdown.sh
#!/bin/bash

# Set timeout values
INACTIVITY_TIMEOUT=300  # 5 minutes after last user disconnects
INITIAL_TIMEOUT=3600    # 60 minutes if no user has connected

# Function to check for active SSH sessions
check_ssh_sessions() {
  if who | grep -q 'pts/'; then
    echo "active"
  else
    echo "inactive"
  fi
}

# Calculate the earliest stop time initially
earliest_stop_time=$(($(date +%s) + INITIAL_TIMEOUT))

# Main loop
while true; do
  current_time=$(date +%s)

  if [[ $(check_ssh_sessions) == "active" ]]; then
    # Reset the earliest stop time to 5 minutes from now
    earliest_stop_time=$(($(date +%s) + INACTIVITY_TIMEOUT))
  elif [[ $current_time -ge $earliest_stop_time ]]; then
    # Shutdown if the current time is past the earliest stop time
    shutdown now
    break
  fi

  # Wait for 1 minute before checking again
  sleep 60
done
EOF'
sudo chmod +x /usr/local/bin/ec2-inactivity-shutdown.sh
sudo bash -c 'cat << "EOF" > /etc/systemd/system/ec2-inactivity-shutdown.service
[Unit]
Description=EC2 Inactivity Shutdown Service

[Service]
Type=simple
ExecStart=/usr/local/bin/ec2-inactivity-shutdown.sh
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF'
sudo systemctl daemon-reload
sudo systemctl enable ec2-inactivity-shutdown.service
sudo systemctl start ec2-inactivity-shutdown.service
