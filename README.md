### README for TractorBeam

# TractorBeam

Welcome to **TractorBeam**! Just like an alien tractor beam that sucks up everything in its path, TractorBeam is a powerful and versatile web scraping tool designed to download website content efficiently. Whether it's good or bad, TractorBeam doesn't decide – you do!

## Overview

TractorBeam is a modular, extensible, and user-friendly web scraping tool that runs seamlessly from a USB drive. It ensures all operations and logs stay within its own file structure, leaving no trace outside. This tool is perfect for anyone needing to gather web content systematically and efficiently.

## Directory Structure

TractorBeam's directory structure is organized to keep everything neat and easily accessible:

```
TractorBeam/
├── bin/
│   ├── TractorBeam.sh
│   ├── auth_script.sh
│   ├── other_scripts.sh
│   ├── email_notification.sh
│   ├── proxy_setup.sh
│   ├── file_filtering.sh
│   ├── scheduling.sh
│   └── gui.sh
├── config/
│   ├── site_urls.txt
│   └── config.cfg
├── logs/
│   └── download.log
├── modules/
│   ├── input_handling.sh
│   ├── option_selection.sh
│   └── execution.sh
├── gui/
│   ├── README.md
│   ├── gui_main.sh
│   ├── gui_styles.css
│   └── gui_config.json
└── README.md
```

## Getting Started

### Step 1: Initialization (Skip if you have cloned the repository)

Run the initialization script to set up the directory structure and create placeholder files:

```bash
bash init_setup.sh
```

### Step 2: Configuration

1. **Add Target URLs**: Edit `config/site_urls.txt` to include the URLs of the sites you want to scrape.
2. **Configure Settings**: Edit `config/config.cfg` to customize settings like retry count, timeout, user agent, and download rate.

### Step 3: Running TractorBeam

Execute the main script to start scraping:

```bash
bash bin/TractorBeam.sh
```

## Key Features

- **Modular Design**: Easy to extend and modify. Add or update scripts in the `bin` and `modules` directories as needed.
- **Self-Contained Operation**: All operations, logs, and configurations stay within the TractorBeam directory.
- **HTTPS Handling**: Can handle HTTPS sites and supports authentication through the `auth_script.sh`.
- **User-Friendly**: Interactive prompts guide you through configuration options.
- **GUI Placeholder**: Ready for future GUI integration with placeholders in the `gui` directory.

## Detailed Description

### bin/

- **TractorBeam.sh**: The main script that orchestrates the web scraping.
- **auth_script.sh**: Handles authentication if required by the target site.
- **other_scripts.sh**: Placeholder for additional scripts.
- **email_notification.sh**: Sends email notifications upon completion or failure. Edit the `config/config.cfg` file to set the recipient email address.
- **proxy_setup.sh**: Configures proxy settings for the scraper. Edit the `config/config.cfg` file to set the HTTP and HTTPS proxy addresses.
- **file_filtering.sh**: Filters which files to download based on extension or other criteria. Edit the `config/config.cfg` file to set the accept and reject file patterns.
- **scheduling.sh**: Schedules scraping tasks using cron. Edit the `config/config.cfg` file to set the schedule and command to be scheduled.
- **gui.sh**: Placeholder for GUI interactions.

### config/

- **site_urls.txt**: List of target URLs for scraping.
- **config.cfg**: Configuration settings for TractorBeam.
    - **Email Notification**: Set the recipient email address.
        ```ini
        EMAIL_NOTIFICATION_RECIPIENT="your-email@example.com"
        ```
    - **Proxy Settings**: Set the HTTP and HTTPS proxy addresses.
        ```ini
        HTTP_PROXY=""
        HTTPS_PROXY=""
        ```
    - **File Filtering**: Set the accept and reject file patterns.
        ```ini
        ACCEPT_FILES=""
        REJECT_FILES=""
        ```
    - **Scheduling**: Set the schedule and command to be scheduled.
        ```ini
        SCHEDULE=""
        COMMAND_TO_SCHEDULE=""
        ```
    - **Configuration Mode**: Set the default configuration mode to easy or advanced.
        ```ini
        #CONFIG_MODE="easy"  # Uncomment to set default configuration mode
        ```

### logs/

- **download.log**: Log file capturing details of the scraping operations.

### modules/

- **input_handling.sh**: Handle user input and interactions.
- **option_selection.sh**: Manage option selections and configurations.
- **execution.sh**: Execute the scraping tasks.

### gui/

- **README.md**: Documentation for GUI components.
- **gui_main.sh**: Main script for the GUI.
- **gui_styles.css**: Styles for the GUI.
- **gui_config.json**: Configuration for the GUI.

## Future Plans

- **GUI Implementation**: Develop a full-featured GUI for ease of use.
- **Advanced Scheduling**: More robust scheduling options.
- **Enhanced Filtering**: Improved file filtering and data extraction capabilities.
- **Cloud Integration**: Upload scraped data directly to cloud storage solutions.

## Contributing

We welcome contributions! Feel free to fork the repository and submit pull requests. If you encounter any issues, please open an issue on the GitHub repository.

## License

TractorBeam is licensed under the GNU General Public License v3.0 License. See the LICENSE file for more details.

---

Just like a hungry UFO tractor beam, TractorBeam is always ready to help you gather the web content you need. Use it wisely and enjoy the power at your fingertips! 🚀

---
