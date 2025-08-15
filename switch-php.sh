#!/bin/bash
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo"
    exit 1
fi

# Check if dnf is available
if ! command -v dnf &> /dev/null; then
    echo "Error: dnf package manager not found. This script is for Fedora/RHEL/CentOS systems."
    exit 1
fi

echo "Updating package repositories..."
dnf makecache --refresh

echo "Fetching available PHP module streams..."
PHP_MODULES=$(dnf module list php | grep -E 'remi|php' | grep -v '^Name' | awk '{print $2}' | sort | uniq)

if [ -z "$PHP_MODULES" ]; then
    echo "No PHP modules found!"
    echo "You may need to install Remi's repository first:"
    echo "sudo dnf install https://rpms.remirepo.net/fedora/remi-release-$(rpm -E %fedora).rpm"
    exit 1
fi

# List versions
echo "Available PHP versions:"
count=1
declare -A PHP_VERSION_MAP
for stream in $PHP_MODULES; do
    PHP_VERSION_MAP[$count]=$stream
    echo "$count) $stream"
    ((count++))
done

read -p "Enter the number of PHP version to enable: " choice

if [[ -z "${PHP_VERSION_MAP[$choice]}" ]]; then
    echo "Invalid choice."
    exit 1
fi

SELECTED_STREAM=${PHP_VERSION_MAP[$choice]}
echo "Switching to PHP version: $SELECTED_STREAM"

# Clean up existing PHP installation
echo "Removing existing PHP packages..."
dnf remove 'php*' -y

# Reset and enable module
echo "Resetting PHP modules..."
dnf module reset php -y

echo "Enabling PHP $SELECTED_STREAM..."
dnf module enable "php:$SELECTED_STREAM" -y

echo "Installing PHP core packages..."
dnf install -y php-cli php-common php-fpm

# Verify installation
if ! command -v php &> /dev/null; then
    echo "PHP installation failed! Trying alternative method..."
    dnf install -y @php:$SELECTED_STREAM
fi

echo "✅ PHP version switched successfully:"
php -v

echo "Additional PHP modules can be installed with:"
echo "sudo dnf install php-{mysqlnd,gd,mbstring,json,...}"
