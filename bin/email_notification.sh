#!/bin/bash

# Load configuration settings
CONFIG_DIR=$(dirname "$0")/../config
LOG_DIR=$(dirname "$0")/../logs
LOG_FILE="$LOG_DIR/email_notification.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Function to log messages
log_message() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

# Function to send an email notification
send_email() {
    local subject="$1"
    local message="$2"
    local recipient="$3"
    
    echo "$message" | mail -s "$subject" "$recipient"
    if [ $? -eq 0 ]; then
        log_message "Email sent successfully: Subject='$subject', Recipient='$recipient'"
    else
        log_message "Failed to send email: Subject='$subject', Recipient='$recipient'"
    fi
}

# Read recipient email from config
source "$CONFIG_DIR/config.cfg"
RECIPIENT_EMAIL=${EMAIL_NOTIFICATION_RECIPIENT:-"user@example.com"}

# Check if email settings are configured
if [ "$RECIPIENT_EMAIL" == "user@example.com" ]; then
    log_message "Warning: Email recipient is set to the default value. Please configure the recipient email in config.cfg."
fi

# Example usage: send_email "Download Completed" "Your download has finished." "$RECIPIENT_EMAIL"
