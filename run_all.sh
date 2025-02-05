#!/bin/bash

# Define script names in order
SCRIPTS=(
  "01_setup_prerequisites.sh"
  "02_install_ocserv.sh"
  "03_generate_ssl.sh"
  "04_configure_ocserv.sh"
  "05_configure_nat.sh"
  "06_create_vpn_user.sh"
  "07_connect_vpn.sh"
)

# Make sure all scripts are in the same directory
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Function to execute each script
run_script() {
  local script="$1"
  echo "-----------------------------------------"
  echo "Running $script..."
  echo "-----------------------------------------"
  
  # Check if script exists and is executable
  if [[ -f "$SCRIPT_DIR/$script" && -x "$SCRIPT_DIR/$script" ]]; then
    "$SCRIPT_DIR/$script"
  else
    echo "Error: $script not found or not executable!"
    exit 1
  fi
}

# Execute each script in order
for script in "${SCRIPTS[@]}"; do
  run_script "$script"
done

echo "-----------------------------------------"
echo "✅ All scripts have been executed successfully!"
echo "-----------------------------------------"
