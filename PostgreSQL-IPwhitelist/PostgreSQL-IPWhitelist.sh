#!/bin/bash

# Default values
subscription_id=""
resource_group=""
server_name=""
csv_file=""

# Function to display usage
usage() {
    echo "Usage: $0 -s <subscription_id> -r <resource_group> -n <server_name> -f <csv_file>"
    exit 1
}

# Parse command-line options
while getopts ":s:r:n:f:" opt; do
    case ${opt} in
        s ) subscription_id=$OPTARG ;;
        r ) resource_group=$OPTARG ;;
        n ) server_name=$OPTARG ;;
        f ) csv_file=$OPTARG ;;
        \? ) usage ;;
    esac
done
shift $((OPTIND -1))

# Check if all required parameters are provided
if [ -z "$subscription_id" ] || [ -z "$resource_group" ] || [ -z "$server_name" ] || [ -z "$csv_file" ]; then
    usage
fi

# Set the Azure subscription
az account set --subscription "$subscription_id"

# Validate CSV file
if [ ! -f "$csv_file" ]; then
    echo "CSV file not found: $csv_file"
    exit 1
fi

# Read IP addresses from the CSV file and create firewall rules
while IFS=',' read -r ip_address
do
    # Skip empty lines
    if [ -z "$ip_address" ]; then
        continue
    fi
    
    # Create a firewall rule for each IP address
    az postgres server firewall-rule create \
        --resource-group "$resource_group" \
        --server-name "$server_name" \
        --name "Rule-$ip_address" \
        --start-ip-address "$ip_address" \
        --end-ip-address "$ip_address"
        
    echo "Firewall rule created for $ip_address"
done < "$csv_file"
