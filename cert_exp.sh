#!/bin/bash
# <---------------------------------------------->
# | Cert Expiry Checker                          |
# | 0 5 * * * cert_exp 2>&1 | logger -t cert_exp |
# | Bendahon 2025                                |
# | Ghetto Gospel                                |
# <---------------------------------------------->

# Changelog
# V1.0 - Initial Release
#

# Yes this is a little vibey

# --- Configuration ---
# This is the array where you edit your list of hosts
# Add or remove hosts from this list
declare -a hosts_to_check=(
  "google.com"
  "facebook.com"
)

# Make sure it exists with something like
# sudo mkdir -p $output_dir
# sudo chown user:user $output_dir
output_dir="/usr/local/ssl"

# --- Don't edit below this line unless you know what you're doing ---

# Main function to process the hosts
check_all_certs() {
  echo "Starting certificate check run at $(date)"

  # Ensure the output directory exists
  mkdir -p "$output_dir"
  if [ ! -d "$output_dir" ]; then
    echo "Error: Could not create output directory: $output_dir" >&2
    exit 1
  fi
  
  # Get the current date in epoch seconds (seconds since 1970)
  local current_epoch=$(date +%s)

  # Loop through each host in the array
  for host in "${hosts_to_check[@]}"; do
    
    # Use the host as the filename
    local output_file="$output_dir/$host.txt"

    echo "Processing: $host"

    # Use openssl to connect and get the cert's end date
    # -servername: Essential for hosts that share an IP (SNI)
    # < /dev/null: Prevents openssl from hanging
    # 2>/dev/null: Suppresses connection/handshake errors
    local expiry_date=$(openssl s_client -connect "${host}:443" -servername "${host}" < /dev/null 2>/dev/null |
                        openssl x509 -noout -enddate 2>/dev/null |
                        cut -d'=' -f2)

    # Check if we got a date
    if [ -n "$expiry_date" ]; then
      # --- Calculation logic ---
      # 1. Convert the text expiry date to epoch seconds
      local expiry_epoch=$(date -d "$expiry_date" +%s)
      # 2. Calculate the difference in seconds
      local diff_seconds=$(( expiry_epoch - current_epoch ))
      # 3. Convert seconds to days (86400 seconds in a day)
      local days_left=$(( diff_seconds / 86400 ))
      # Save the number of days to the file
      echo "$days_left" > "$output_file"
      echo "  -> OK: $days_left days left. Saved to $output_file"
      
    else
      # Log an error if the command failed
      local error_msg="Error: Could not get expiry date for $host"
      echo "$error_msg" > "$output_file"
      echo "  -> $error_msg" >&2
    fi
  done

  echo "Certificate check complete."
}

# --- Run the function ---
check_all_certs 
