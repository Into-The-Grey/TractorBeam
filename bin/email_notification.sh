#!/bin/bash

# Placeholder for email notification script

# Function to send an email notification
send_email() {
    local subject="$1"
    local message="$2"
    local recipient="$3"
    
    echo "$message" | mail -s "$subject" "$recipient"
}

# Read recipient email from config
source $(dirname "$0")/../config/config.cfg
RECIPIENT_EMAIL=${EMAIL_NOTIFICATION_RECIPIENT:-"user@example.com"}

# Example usage: send_email "Download Completed" "Your download has finished." "$RECIPIENT_EMAIL"
