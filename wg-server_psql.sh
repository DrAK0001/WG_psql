#!/bin/bash

# Replace these with your database credentials and table/column names
PG_HOST="your_host"
PG_USER="your_username"
PG_DB="your_database"
PG_TABLE="your_table"
WG_CONFIG_FILE="/etc/wireguard/wg0.conf"  # Replace with your WireGuard config file path

# Fetch peer data from PostgreSQL database
peer_data=$(psql -h $PG_HOST -U $PG_USER -d $PG_DB -t -c "SELECT public_key, ip_address FROM $PG_TABLE")

# Check if there is any data retrieved
if [ -z "$peer_data" ]; then
    echo "No peer data found in the database."
    exit 1
fi

# Clear existing WireGuard config file
echo "" > $WG_CONFIG_FILE

# Add WireGuard server configuration
echo "[Interface]" >> $WG_CONFIG_FILE
echo "ListenPort 51820" >> $WG_CONFIG_FILE
echo "PrivateKey <your_server_private_key>" >> $WG_CONFIG_FILE  # Replace with your server's private key

# Add peer configurations
IFS=$'\n'  # Set the Internal Field Separator to newline to iterate over lines
for line in $peer_data; do
    public_key=$(echo $line | cut -d '|' -f 1)
    ip_address=$(echo $line | cut -d '|' -f 2)
    
    echo "" >> $WG_CONFIG_FILE
    echo "[Peer]" >> $WG_CONFIG_FILE
    echo "PublicKey $public_key" >> $WG_CONFIG_FILE
    echo "AllowedIPs $ip_address/32" >> $WG_CONFIG_FILE
done

# Restart WireGuard to apply the new configuration (you may need appropriate privileges)
systemctl restart wg-quick@wg0  # Replace with your WireGuard service name

echo "WireGuard configuration file updated."
