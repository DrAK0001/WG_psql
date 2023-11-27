#!/bin/bash

# Generate WireGuard keys
private_key=$(wg genkey)
public_key=$(echo "$private_key" | wg pubkey)

# Prompt for IP address
read -p "Enter IP address: " ip_address

# Get hostname
hostname=$(hostname)

# Send data to PostgreSQL database
# Assuming you have psql installed and configured
# Replace placeholders with your actual database credentials and table/column names
PG_HOST="your_host"
PG_USER="your_username"
PG_DB="your_database"
PG_TABLE="your_table"

# Insert data into PostgreSQL
echo "INSERT INTO $PG_TABLE (private_key, public_key, ip_address, hostname) VALUES ('$private_key', '$public_key', '$ip_address', '$hostname');" | psql -h $PG_HOST -U $PG_USER -d $PG_DB
