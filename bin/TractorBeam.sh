#!/bin/bash

# Load configurations
source $(dirname "$0")/../config/config.cfg
source $(dirname "$0")/../config/auth.cfg

# Initialize variables
PROPOSED_CMD="wget"
DESCRIPTION=""
RISK_LEVEL="Low"
ETHICAL_LEVEL="High"

# Function to prompt user and get a yes/no response
ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to log messages
log_message() {
    echo "$(date) - $1" >> $(dirname "$0")/../logs/download.log
}

# Function to update and display the proposed command
update_proposed_command() {
    echo "Proposed Command: $PROPOSED_CMD"
    echo "Description: $DESCRIPTION"
    echo "Risk Level: $RISK_LEVEL"
    echo "Ethical Level: $ETHICAL_LEVEL"
}

# Function to scan website
scan_website() {
    echo "Select a scanning tool:"
    echo "1. Wget with Depth Limit"
    echo "2. HTTrack"
    echo "3. Scrapy"
    read -p "Enter your choice (1-3): " choice
    case $choice in
        1)
            read -p "Enter the depth limit: " DEPTH
            PROPOSED_CMD="wget --spider -r -l $DEPTH"
            DESCRIPTION="Basic scanning using wget with depth limit $DEPTH"
            ;;
        2)
            PROPOSED_CMD="httrack"
            DESCRIPTION="Advanced scanning using HTTrack"
            ;;
        3)
            PROPOSED_CMD="scrapy"
            DESCRIPTION="Advanced scanning using Scrapy"
            ;;
        *)
            echo "Invalid choice"
            scan_website
            ;;
    esac
    update_proposed_command
}

# Check if site_urls.txt exists
if [ -f $(dirname "$0")/../config/site_urls.txt ]; then
    URLS=$(cat $(dirname "$0")/../config/site_urls.txt)
else
    read -p "Enter the target URL: " URL
    URLS=$URL
fi

# Scan the website
scan_website

# Inform user about HTTPS
if [[ $URL == https* ]]; then
    echo "The URL uses HTTPS, which may require authentication."
    if ask_yes_no "Would you like to run an initial script to collect required authentication data?"; then
        bash $(dirname "$0")/auth_script.sh
        USE_COOKIES=true
    fi
fi

# Ask for options and update proposed command
SSL_CHECKS=false
if ask_yes_no "Would you like to bypass SSL certificate checks?"; then
    SSL_CHECKS=true
    PROPOSED_CMD="$PROPOSED_CMD --no-check-certificate"
    DESCRIPTION="$DESCRIPTION | Bypass SSL certificate checks"
    RISK_LEVEL="Medium"
    ETHICAL_LEVEL="Medium"
    update_proposed_command
fi

if ask_yes_no "Would you like to limit the download rate? (Default: 200k)?"; then
    read -p "Enter the desired download rate (e.g., 200k, 1m): " LIMIT_RATE
    PROPOSED_CMD="$PROPOSED_CMD --limit-rate=$LIMIT_RATE"
    DESCRIPTION="$DESCRIPTION | Limit download rate to $LIMIT_RATE"
    update_proposed_command
fi

if ask_yes_no "Would you like to set the User-Agent header? (Default: Mozilla/5.0)?"; then
    read -p "Enter the User-Agent string: " USER_AGENT
    PROPOSED_CMD="$PROPOSED_CMD -U \"$USER_AGENT\""
    DESCRIPTION="$DESCRIPTION | Set User-Agent to $USER_AGENT"
    update_proposed_command
fi

if ask_yes_no "Would you like to specify the number of retries for failed downloads? (Default: 5)?"; then
    read -p "Enter the number of retries: " RETRIES
    PROPOSED_CMD="$PROPOSED_CMD --tries=$RETRIES"
    DESCRIPTION="$DESCRIPTION | Set retries to $RETRIES"
    update_proposed_command
fi

if ask_yes_no "Would you like to set the timeout for connections? (Default: 30s)?"; then
    read -p "Enter the timeout in seconds: " TIMEOUT
    PROPOSED_CMD="$PROPOSED_CMD --timeout=$TIMEOUT"
    DESCRIPTION="$DESCRIPTION | Set timeout to $TIMEOUT seconds"
    update_proposed_command
fi

if ask_yes_no "Would you like to set the wait time between retries? (Default: 10s)?"; then
    read -p "Enter the wait time in seconds: " WAITRETRY
    PROPOSED_CMD="$PROPOSED_CMD --waitretry=$WAITRETRY"
    DESCRIPTION="$DESCRIPTION | Set wait retry to $WAITRETRY seconds"
    update_proposed_command
fi

# Log the start of the download
log_message "Starting download of $URLS"

# Construct final wget command
WGET_CMD="$PROPOSED_CMD $URLS"

# Include authentication credentials if available
if [ -n "$AUTH_CREDENTIALS" ]; then
    WGET_CMD="$WGET_CMD $AUTH_CREDENTIALS"
fi

# Include cookies if available
if [ -f "$COOKIE_FILE" ]; then
    WGET_CMD="$WGET_CMD --load-cookies=$COOKIE_FILE"
fi

# Execute wget command
echo "Executing: $WGET_CMD"
eval $WGET_CMD

# Check if the first attempt failed due to SSL issues
if [ $? -ne 0 ]; then
    log_message "First attempt failed, retrying with --no-check-certificate option..."
    if ! $SSL_CHECKS; then
        WGET_CMD="$WGET_CMD --no-check-certificate"
        eval $WGET_CMD
    fi
fi

log_message "Download completed."
