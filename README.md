# Fedora PHP Version Switcher

A bash script to easily switch between different PHP versions on Fedora/RHEL/CentOS systems using Remi's repository.

## Features

- Lists all available PHP versions from Remi's repository
- Completely removes existing PHP packages before switching
- Supports PHP 7.4 through 8.4
- Installs core PHP packages (cli, common, fpm)
- Provides verification of successful version switch

## Prerequisites

- Fedora/RHEL/CentOS system
- sudo/root access
- dnf package manager
- Remi's repository (will prompt to install if missing)

## Installation

1. Download the script:
```bash
curl -O https://gist.githubusercontent.com/yourusername/scriptid/raw/switch-php.sh
Make it executable:

bash
chmod +x switch-php.sh
Usage
Run as root/sudo:

bash
sudo ./switch-php.sh
Follow the on-screen prompts to:

Select your desired PHP version

Let the script handle the switching process

Verify the new PHP version

Example Output
text
Available PHP versions:
1) remi-7.4
2) remi-8.0
3) remi-8.1
4) remi-8.2
5) remi-8.3
6) remi-8.4
Enter the number of PHP version to enable: 6
Switching to PHP version: remi-8.4
...
✅ PHP version switched successfully:
PHP 8.4.0 (cli) (built: Nov 15 2023 12:34:56)
Troubleshooting
GLIBC Errors
If you encounter GLIBC version errors:

bash
sudo dnf upgrade glibc
sudo dnf distro-sync
Repository Issues
If no PHP versions appear:

bash
sudo dnf install https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm
Partial Upgrades
If the wrong version remains installed:

bash
sudo dnf remove php-\* -y
sudo ./switch-php.sh
License
MIT License - Free for modification and distribution

Contributing
Pull requests welcome! Please:

Keep compatibility with Fedora's dnf

Maintain clean package removal

Add tests if possible

text

This README provides:
1. Clear installation/usage instructions
2. Expected output example
3. Common troubleshooting solutions
4. Project metadata
5. Contribution guidelines

Would you like me to add any additional sections or modify any part of this documentation?