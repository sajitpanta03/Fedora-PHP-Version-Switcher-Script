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

PHP_MODULES=$(dnf module list php 2>/dev/null \
    | grep -E 'remi|php' \
    | grep -v '^Name' \
    | awk '{print $2}' \
    | sort -V \
    | uniq)

if [ -z "$PHP_MODULES" ]; then
    echo "No PHP modules found!"
    echo "You may need to install Remi's repository first:"
    echo "sudo dnf install https://rpms.remirepo.net/fedora/remi-release-\$(rpm -E %fedora).rpm"
    exit 1
fi

echo
echo "Available PHP versions:"
echo "-----------------------"

count=1
declare -A PHP_VERSION_MAP

for stream in $PHP_MODULES; do
    PHP_VERSION_MAP[$count]=$stream
    echo "$count) $stream"
    ((count++))
done

echo
read -p "Enter the number of PHP version to enable: " choice

if [[ -z "${PHP_VERSION_MAP[$choice]}" ]]; then
    echo "Invalid choice."
    exit 1
fi

SELECTED_STREAM=${PHP_VERSION_MAP[$choice]}

echo
echo "Switching to PHP version: $SELECTED_STREAM"
echo

# Remove existing PHP packages
echo "Removing existing PHP packages..."
dnf remove 'php*' -y || true

# Reset PHP module
echo "Resetting PHP modules..."
dnf module reset php -y

# Enable selected PHP version
echo "Enabling PHP $SELECTED_STREAM..."
dnf module enable "php:$SELECTED_STREAM" -y

# Install PHP + common extensions
echo
echo "Installing PHP and extensions..."

dnf install -y \
    php \
    php-cli \
    php-common \
    php-fpm \
    php-mysqlnd \
    php-pgsql \
    php-sqlite3 \
    php-mbstring \
    php-xml \
    php-json \
    php-curl \
    php-gd \
    php-zip \
    php-bcmath \
    php-intl \
    php-opcache \
    php-soap \
    php-readline \
    php-process \
    php-fileinfo \
    php-tokenizer \
    php-dom \
    php-simplexml \
    php-xmlreader \
    php-xmlwriter

echo
echo "======================================"
echo " PHP installation completed"
echo "======================================"
echo

php -v

echo
echo "Checking important PHP extensions..."
echo

REQUIRED_EXTENSIONS=(
    "PDO"
    "pdo_mysql"
    "mysqli"
    "mbstring"
    "xml"
    "dom"
    "curl"
    "fileinfo"
    "openssl"
    "tokenizer"
    "ctype"
    "json"
    "bcmath"
    "intl"
    "zip"
    "gd"
    "opcache"
)

for ext in "${REQUIRED_EXTENSIONS[@]}"; do
    if php -m | grep -qi "^$ext$"; then
        echo "✅ $ext"
    else
        echo "❌ $ext MISSING"
    fi
done

echo
echo "PHP location:"
which php

echo
echo "Loaded php.ini:"
php --ini

echo
echo "PHP-FPM status:"
systemctl enable --now php-fpm

echo
echo "======================================"
echo " PHP $SELECTED_STREAM is ready!"
echo "======================================"
echo
echo "Useful commands:"
echo "  php -v"
echo "  php -m"
echo "  php --ini"
echo "  systemctl status php-fpm"
echo