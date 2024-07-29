#!/bin/bash

# Load configuration settings
CONFIG_DIR=$(dirname "$0")/../config
LOG_DIR=$(dirname "$0")/../logs
LOG_FILE="$LOG_DIR/proxy_setup.log"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Function to log messages
log_message() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

# Function to configure proxy settings
configure_proxy() {
    local http_proxy="$1"
    local https_proxy="$2"
    
    export http_proxy="$http_proxy"
    export https_proxy="$https_proxy"
    
    if [ -n "$http_proxy" ]; then
        log_message "HTTP proxy set to $http_proxy"
    else
        log_message "HTTP proxy not set"
    fi

    if [ -n "$https_proxy" ]; then
        log_message "HTTPS proxy set to $https_proxy"
    else
        log_message "HTTPS proxy not set"
    fi
}

# Read proxy settings from config
source "$CONFIG_DIR/config.cfg"
HTTP_PROXY=${HTTP_PROXY:-""}
HTTPS_PROXY=${HTTPS_PROXY:-""}

# Apply proxy settings
configure_proxy "$HTTP_PROXY" "$HTTPS_PROXY"
