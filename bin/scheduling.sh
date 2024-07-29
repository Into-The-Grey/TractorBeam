#!/bin/bash

# Load configuration settings
CONFIG_DIR=$(dirname "$0")/../config
LOG_DIR=$(dirname "$0")/../logs
LOG_FILE="$LOG_DIR/scheduling.log"

# Ensure the log directory and file exist
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# Function to log messages
log_message() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

# Function to schedule a task using cron
schedule_task() {
    local schedule="$1"
    local command="$2"
    
    (crontab -l ; echo "$schedule $command") | crontab -
    log_message "Task scheduled: $schedule $command"
    echo "Task scheduled: $schedule $command"
}

# Function to delete a scheduled task
delete_task() {
    local command="$1"
    
    crontab -l | grep -v "$command" | crontab -
    log_message "Task deleted: $command"
    echo "Task deleted: $command"
}

# Function to display scheduled tasks
display_tasks() {
    echo "Scheduled tasks:"
    crontab -l
}

# Read scheduling settings from config
source "$CONFIG_DIR/config.cfg"
SCHEDULE=${SCHEDULE:-""}
COMMAND_TO_SCHEDULE=${COMMAND_TO_SCHEDULE:-""}

# Ask user for action
echo "What would you like to do?"
echo "1. Schedule a task"
echo "2. Delete a scheduled task"
echo "3. Display scheduled tasks"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        if [ -n "$SCHEDULE" ] && [ -n "$COMMAND_TO_SCHEDULE" ]; then
            schedule_task "$SCHEDULE" "$COMMAND_TO_SCHEDULE"
        else
            read -p "Enter the schedule (e.g., '0 5 * * *'): " SCHEDULE
            read -p "Enter the command to schedule: " COMMAND_TO_SCHEDULE
            schedule_task "$SCHEDULE" "$COMMAND_TO_SCHEDULE"
        fi
        ;;
    2)
        read -p "Enter the command to delete: " COMMAND_TO_DELETE
        delete_task "$COMMAND_TO_DELETE"
        ;;
    3)
        display_tasks
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
