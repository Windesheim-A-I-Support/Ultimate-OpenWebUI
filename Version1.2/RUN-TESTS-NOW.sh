#!/bin/bash
# Quick test runner - prompts for credentials
# Run this script to test OpenWebUI

echo "======================================================"
echo "OpenWebUI Automated Testing Suite"
echo "======================================================"
echo ""

# Check if credentials provided as arguments
if [ $# -eq 2 ]; then
    EMAIL=$1
    PASSWORD=$2
else
    # Prompt for credentials
    echo "Enter your OpenWebUI admin credentials:"
    read -p "Email: " EMAIL
    read -s -p "Password: " PASSWORD
    echo ""
fi

echo ""
echo "Starting tests with credentials: $EMAIL"
echo ""

# Run the comprehensive test suite
./run-all-tests.sh "$EMAIL" "$PASSWORD" "https://team1-openwebui.valuechainhackers.xyz"
