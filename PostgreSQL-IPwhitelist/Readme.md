
# Create PostgreSQL Firewall Rules Script

## Overview

This script creates firewall rules for an Azure PostgreSQL server based on IP addresses listed in a CSV file. The script allows for parameterized input to specify the Azure subscription, resource group, server name, and the path to the CSV file containing the IP addresses.

## Usage

### 1. Prepare Your Environment

1. **Install Azure CLI**:
   - Follow the [official installation guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) to install the Azure CLI on your system.

2. **Login to Azure**:
   ```bash
   az login
   ```

### 2. Prepare Your CSV File

1. **Create a CSV File**:
   - The CSV file should contain a list of IP addresses, one per line.
   - Example format:
     ```csv
     192.168.1.1
     192.168.1.2
     ```

### 3. Run the Script

1. **Save the Script**:
   - Save the improved script as `create_firewall_rules.sh`.

2. **Make the Script Executable**:
   ```bash
   chmod +x create_firewall_rules.sh
   ```

3. **Run the Script with Parameters**:
   ```bash
   ./create_firewall_rules.sh -s "<subscription_id>" -r "<resource_group>" -n "<server_name>" -f "<csv_file>"
   ```

   - Replace `<subscription_id>` with your Azure subscription ID.
   - Replace `<resource_group>` with the name of your Azure resource group.
   - Replace `<server_name>` with the name of your PostgreSQL server.
   - Replace `<csv_file>` with the path to your CSV file containing IP addresses.

### Parameters

- `-s <subscription_id>`: Azure subscription ID to use for the operations.
- `-r <resource_group>`: Resource group containing the PostgreSQL server.
- `-n <server_name>`: Name of the PostgreSQL server.
- `-f <csv_file>`: Path to the CSV file containing IP addresses.

### Script Content

```bash
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
        --name "INC1138692-$ip_address" \
        --start-ip-address "$ip_address" \
        --end-ip-address "$ip_address"
        
    echo "Firewall rule created for $ip_address"
done < "$csv_file"
```

## Notes

- Ensure all parameters are correctly provided when running the script.
- Modify the script as needed to fit your specific environment and requirements.
