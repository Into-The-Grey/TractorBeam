#!/bin/bash

# Load configurations
CONFIG_DIR=$(dirname "$0")/../config
LOG_DIR=$(dirname "$0")/../logs
LOG_FILE="$LOG_DIR/tractorbeam.log"
CONFIG_FILE="$CONFIG_DIR/config.cfg"

# Ensure the log directory and file exist
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# Function to log messages
log_message() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

# Function to display ASCII art
display_ascii_art() {
    clear
    case $ASCII_ART_PREF in
        "logo")
            echo "Logo feature coming soon!"
            ;;
        "name")
            cat "$CONFIG_DIR/TRACTORBEAM_label_ascii_art.txt"
            ;;
        *)
            cat "$CONFIG_DIR/TRACTORBEAM_label_ascii_art.txt"
            ;;
    esac
    echo -e "\n"
}

# Function to ask for ASCII art preference
ask_ascii_preference() {
    echo "Do you prefer:"
    echo "1. Name"
    echo "2. None"
    read -p "Enter your choice (1-2): " choice
    case $choice in
        1)
            ASCII_ART_PREF="name"
            ;;
        2)
            ASCII_ART_PREF="none"
            ;;
        *)
            echo "Invalid choice"
            ask_ascii_preference
            ;;
    esac
    echo "ASCII_ART_PREF=\"$ASCII_ART_PREF\"" >> "$CONFIG_FILE"
}

# Function to check necessary files with a progress bar
check_files() {
    local files=("$CONFIG_DIR/TRACTORBEAM_label_ascii_art.txt" "$CONFIG_DIR/Welcome_to_TRACTORBEAM_ascii_art.txt")
    local total=${#files[@]}
    local progress=0
    echo "Checking necessary files..."
    for file in "${files[@]}"; do
        sleep 0.5 # Simulate file check
        if [ -f "$file" ]; then
            echo -ne "[$progress%] Checking $file: OK\r"
        else
            echo -ne "[$progress%] Checking $file: MISSING\r"
        fi
        progress=$((progress + 100 / total))
    done
    echo -e "\nFile check completed."
}

# Load user preferences or ask if running for the first time
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    touch "$CONFIG_FILE"
    cat "$CONFIG_DIR/Welcome_to_TRACTORBEAM_ascii_art.txt"
    ask_ascii_preference
fi

# Perform file checks with progress bars
check_files

# Function to show main menu
show_main_menu() {
    display_ascii_art
    echo "Please select an option:"
    echo "1. Wget"
    echo "2. Scrapy"
    echo "3. Return (back one level)"
    echo "4. Start over"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            show_wget_menu
            ;;
        2)
            show_scrapy_menu
            ;;
        3)
            return
            ;;
        4)
            confirm_start_over
            ;;
        *)
            echo "Invalid choice"
            show_main_menu
            ;;
    esac
}

# Function to show wget menu
show_wget_menu() {
    echo "Wget Menu"
    echo "1. Option 1"
    echo "2. Option 2"
    echo "3. Return"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            # Implement wget option 1
            ;;
        2)
            # Implement wget option 2
            ;;
        3)
            show_main_menu
            ;;
        *)
            echo "Invalid choice"
            show_wget_menu
            ;;
    esac
}

# Function to show scrapy menu
show_scrapy_menu() {
    echo "Scrapy Menu"
    echo "1. Option 1"
    echo "2. Option 2"
    echo "3. Return"
    read -p "Enter your choice: " choice
    case $choice in
        1)
            # Implement scrapy option 1
            ;;
        2)
            # Implement scrapy option 2
            ;;
        3)
            show_main_menu
            ;;
        *)
            echo "Invalid choice"
            show_scrapy_menu
            ;;
    esac
}

# Function to confirm start over
confirm_start_over() {
    read -p "Are you sure you want to start over? This will reset all configurations. (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -f "$CONFIG_FILE"
        exec "$0"
    else
        show_main_menu
    fi
}

# Show main menu
show_main_menu
