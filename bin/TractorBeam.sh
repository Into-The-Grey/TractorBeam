#!/bin/bash

# Load configurations
CONFIG_DIR=$(dirname "$0")/../config
LOG_DIR=$(dirname "$0")/../logs
LOG_FILE="$LOG_DIR/tractorbeam.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Load other necessary scripts
source "$CONFIG_DIR/config.cfg"
source "$CONFIG_DIR/auth.cfg"
source $(dirname "$0")/email_notification.sh
source $(dirname "$0")/proxy_setup.sh
source $(dirname "$0")/file_filtering.sh
source $(dirname "$0")/scheduling.sh

# Initialize variables
PROPOSED_CMD="wget"
DESCRIPTION=""
RISK_LEVEL="Low"
ETHICAL_LEVEL="High"
CONFIG_MODE=""

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
    echo "$(date) - $1" >> "$LOG_FILE"
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

# Function to ask configuration mode
ask_config_mode() {
    echo "Select configuration mode:"
    echo "1. Easy"
    echo "2. Advanced"
    read -p "Enter your choice (1-2): " choice
    case $choice in
        1)
            CONFIG_MODE="easy"
            ;;
        2)
            CONFIG_MODE="advanced"
            ;;
        *)
            echo "Invalid choice"
            ask_config_mode
            ;;
    esac
}

# Check if site_urls.txt exists
if [ -f "$CONFIG_DIR/site_urls.txt" ]; then
    URLS=$(cat "$CONFIG_DIR/site_urls.txt")
else
    read -p "Enter the target URL: " URL
    URLS=$URL
fi

# Scan the website
scan_website

# Ask for configuration mode
ask_config_mode

# Inform user about HTTPS
if [[ $URL == https* ]]; then
    echo "The URL uses HTTPS, which may require authentication."
    if ask_yes_no "Would you like to run an initial script to collect required authentication data?"; then
        bash $(dirname "$0")/auth_script.sh
        USE_COOKIES=true
    fi
fi

# Wget options

# Options common to both easy and advanced modes
if ask_yes_no "Would you like to bypass SSL certificate checks?"; then
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

if [ "$CONFIG_MODE" == "advanced" ]; then
    # Additional options for advanced mode
    if ask_yes_no "Would you like to convert links in downloaded files?"; then
        PROPOSED_CMD="$PROPOSED_CMD --convert-links"
        DESCRIPTION="$DESCRIPTION | Convert links in downloaded files"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to backup converted files before conversion?"; then
        PROPOSED_CMD="$PROPOSED_CMD --backup-converted"
        DESCRIPTION="$DESCRIPTION | Backup converted files"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to adjust file extension based on MIME type?"; then
        PROPOSED_CMD="$PROPOSED_CMD -E"
        DESCRIPTION="$DESCRIPTION | Adjust file extension based on MIME type"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to follow FTP links from HTML documents?"; then
        PROPOSED_CMD="$PROPOSED_CMD --follow-ftp"
        DESCRIPTION="$DESCRIPTION | Follow FTP links from HTML documents"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to use passive FTP mode?"; then
        PROPOSED_CMD="$PROPOSED_CMD --passive-ftp"
        DESCRIPTION="$DESCRIPTION | Use passive FTP mode"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to timestamp files, only downloading newer files?"; then
        PROPOSED_CMD="$PROPOSED_CMD -N"
        DESCRIPTION="$DESCRIPTION | Timestamp files, only downloading newer files"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to mirror the website (recursively download)?"; then
        PROPOSED_CMD="$PROPOSED_CMD --mirror"
        DESCRIPTION="$DESCRIPTION | Mirror the website"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to randomize wait times between requests?"; then
        PROPOSED_CMD="$PROPOSED_CMD --random-wait"
        DESCRIPTION="$DESCRIPTION | Randomize wait times between requests"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to wait between requests?"; then
        read -p "Enter the wait time in seconds: " WAIT
        PROPOSED_CMD="$PROPOSED_CMD --wait=$WAIT"
        DESCRIPTION="$DESCRIPTION | Wait $WAIT seconds between requests"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to set a custom header?"; then
        read -p "Enter the custom header: " HEADER
        PROPOSED_CMD="$PROPOSED_CMD --header=\"$HEADER\""
        DESCRIPTION="$DESCRIPTION | Set custom header: $HEADER"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to use a custom referer?"; then
        read -p "Enter the referer URL: " REFERER
        PROPOSED_CMD="$PROPOSED_CMD --referer=\"$REFERER\""
        DESCRIPTION="$DESCRIPTION | Use custom referer: $REFERER"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to enable cookies?"; then
        PROPOSED_CMD="$PROPOSED_CMD --cookies=on"
        DESCRIPTION="$DESCRIPTION | Enable cookies"
        update_proposed_command
    fi

        if ask_yes_no "Would you like to disable cookies?"; then
        PROPOSED_CMD="$PROPOSED_CMD --cookies=off"
        DESCRIPTION="$DESCRIPTION | Disable cookies"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to load cookies from a file?"; then
        read -p "Enter the cookie file path: " COOKIE_FILE
        PROPOSED_CMD="$PROPOSED_CMD --load-cookies=$COOKIE_FILE"
        DESCRIPTION="$DESCRIPTION | Load cookies from $COOKIE_FILE"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to save cookies to a file?"; then
        read -p "Enter the cookie file path: " COOKIE_FILE
        PROPOSED_CMD="$PROPOSED_CMD --save-cookies=$COOKIE_FILE"
        DESCRIPTION="$DESCRIPTION | Save cookies to $COOKIE_FILE"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to keep session cookies?"; then
        PROPOSED_CMD="$PROPOSED_CMD --keep-session-cookies"
        DESCRIPTION="$DESCRIPTION | Keep session cookies"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to ignore robots.txt file?"; then
        PROPOSED_CMD="$PROPOSED_CMD -e robots=off"
        DESCRIPTION="$DESCRIPTION | Ignore robots.txt file"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to execute additional wget commands?"; then
        read -p "Enter the additional commands: " ADDITIONAL_CMDS
        PROPOSED_CMD="$PROPOSED_CMD -e $ADDITIONAL_CMDS"
        DESCRIPTION="$DESCRIPTION | Execute additional wget commands: $ADDITIONAL_CMDS"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to limit the download to specific domains?"; then
        read -p "Enter the domain(s) (comma-separated if multiple): " DOMAINS
        PROPOSED_CMD="$PROPOSED_CMD --domains=$DOMAINS"
        DESCRIPTION="$DESCRIPTION | Limit download to domains: $DOMAINS"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to reject specific domains?"; then
        read -p "Enter the domain(s) (comma-separated if multiple): " REJECT_DOMAINS
        PROPOSED_CMD="$PROPOSED_CMD --exclude-domains=$REJECT_DOMAINS"
        DESCRIPTION="$DESCRIPTION | Reject domains: $REJECT_DOMAINS"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to download the website in the background?"; then
        PROPOSED_CMD="$PROPOSED_CMD --background"
        DESCRIPTION="$DESCRIPTION | Download the website in the background"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to remove a directory structure from the file names?"; then
        PROPOSED_CMD="$PROPOSED_CMD --cut-dirs=NUMBER"
        DESCRIPTION="$DESCRIPTION | Remove directory structure from the file names"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to retry downloads until the limit is reached?"; then
        read -p "Enter the number of retries: " RETRY_LIMIT
        PROPOSED_CMD="$PROPOSED_CMD --tries=$RETRY_LIMIT"
        DESCRIPTION="$DESCRIPTION | Retry downloads until the limit is reached"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to continue downloads that were previously interrupted?"; then
        PROPOSED_CMD="$PROPOSED_CMD -c"
        DESCRIPTION="$DESCRIPTION | Continue downloads that were previously interrupted"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to restrict the download to a specific path?"; then
        read -p "Enter the path: " PATH
        PROPOSED_CMD="$PROPOSED_CMD --directory-prefix=$PATH"
        DESCRIPTION="$DESCRIPTION | Restrict download to the path: $PATH"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to specify the download file names?"; then
        read -p "Enter the file names: " FILES
        PROPOSED_CMD="$PROPOSED_CMD -O $FILES"
        DESCRIPTION="$DESCRIPTION | Specify the download file names: $FILES"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to specify the output file?"; then
        read -p "Enter the output file name: " OUTPUT_FILE
        PROPOSED_CMD="$PROPOSED_CMD -o $OUTPUT_FILE"
        DESCRIPTION="$DESCRIPTION | Specify the output file name: $OUTPUT_FILE"
        update_proposed_command
    fi

    if ask_yes_no "Would you like to append to the output file?"; then
        read -p "Enter the output file name: " OUTPUT_FILE
        PROPOSED_CMD="$PROPOSED_CMD -a $OUTPUT_FILE"
        DESCRIPTION="$DESCRIPTION | Append to the output file: $OUTPUT_FILE"
        update_proposed_command
    fi

fi

# Log the start of the download
log_message "Starting download of $URLS"

# Construct final wget command
WGET_CMD="$PROPOSED_CMD $URLS"
WGET_CMD="$WGET_CMD $FILTER_OPTIONS"

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

send_email "Download Completed" "Your download has finished." "$RECIPIENT_EMAIL"

log_message "Download completed."

# Schedule next download
if ask_yes_no "Would you like to schedule the next download?"; then
    schedule_next_download
fi

echo "All done!"
