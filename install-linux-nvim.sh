#!/bin/bash

# nvim-installer.sh - Neovim installation and update script
# This script helps install or update Neovim using the AppImage format on Linux

set -e  # Exit immediately if a command exits with a non-zero status

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NVIM_VERSION="v0.11.1"
DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
APP_DIR="${HOME}/app/nvim"
TEMP_DIR="${HOME}/.cache/nvim-installer"
APPIMAGE_PATH="${TEMP_DIR}/nvim-linux-x86_64.appimage"
SYMLINK_PATH="${HOME}/.local/bin/nvim"

# Function to display messages
print_message() {
    echo -e "${BLUE}[NVIM INSTALLER]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Download the Neovim AppImage
download_nvim() {
    print_message "Downloading Neovim ${NVIM_VERSION}..."
    
    # Make sure the directory exists and is writable
    mkdir -p "$TEMP_DIR"
    
    # Check if we can write to the destination
    if [ ! -w "$TEMP_DIR" ]; then
        print_error "Cannot write to $TEMP_DIR. Check permissions."
        exit 1
    fi
    
    # Check if file exists and remove it if necessary
    if [ -f "$APPIMAGE_PATH" ]; then
        rm -f "$APPIMAGE_PATH" || {
            print_error "Could not remove existing file at $APPIMAGE_PATH. Check permissions."
            exit 1
        }
    fi

    if command -v curl &> /dev/null; then
        curl -L "$DOWNLOAD_URL" -o "$APPIMAGE_PATH" || {
            print_error "Download failed. Check your internet connection and permissions."
            exit 1
        }
    elif command -v wget &> /dev/null; then
        wget "$DOWNLOAD_URL" -O "$APPIMAGE_PATH" || {
            print_error "Download failed. Check your internet connection and permissions."
            exit 1
        }
    else
        print_error "Neither curl nor wget found. Please install one of them and try again."
        exit 1
    fi
    print_success "Download completed!"
}

# Make the AppImage executable
make_executable() {
    print_message "Making AppImage executable..."
    chmod u+x "$APPIMAGE_PATH"
    print_success "AppImage is now executable."
}

# Extract the AppImage
extract_appimage() {
    print_message "Extracting AppImage..."
    
    # Create app directory if it doesn't exist
    mkdir -p "$(dirname "$APP_DIR")"
    
    # Remove old installation if it exists
    if [ -d "$APP_DIR" ]; then
        print_message "Removing old Neovim installation..."
        rm -rf "$APP_DIR"
    fi
    
    # Create a temporary directory for extraction
    EXTRACT_DIR="${TEMP_DIR}/nvim-extract"
    mkdir -p "$EXTRACT_DIR"
    
    # Extract the AppImage
    cd "$TEMP_DIR"
    "$APPIMAGE_PATH" --appimage-extract >/dev/null
    
    # Rename squashfs-root to app/nvim
    if [ -d "squashfs-root" ]; then
        mv "squashfs-root" "$APP_DIR"
        print_success "AppImage extracted to $APP_DIR"
    else
        print_error "Extraction failed: squashfs-root directory not found"
        exit 1
    fi
}

# Create symlink in ~/.local/bin
create_symlink() {
    print_message "Creating symlink to Neovim in $SYMLINK_PATH..."
    
    # Ensure the bin directory exists
    mkdir -p "$(dirname "$SYMLINK_PATH")"
    
    # Check if symlink already exists
    if [ -L "$SYMLINK_PATH" ]; then
        print_message "Removing existing symlink..."
        rm "$SYMLINK_PATH"
    elif [ -e "$SYMLINK_PATH" ]; then
        # If it exists but is not a symlink, backup the file
        print_warning "File exists at $SYMLINK_PATH. Creating backup..."
        mv "$SYMLINK_PATH" "${SYMLINK_PATH}.backup"
    fi
    
    # Create the new symlink
    ln -s "${APP_DIR}/usr/bin/nvim" "$SYMLINK_PATH"
    print_success "Symlink created successfully!"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
        print_warning "${HOME}/.local/bin is not in your PATH."
        print_message "Add the following line to your ~/.bashrc or ~/.zshrc:"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Check for latest version
check_latest_version() {
    print_message "Checking for the latest Neovim version..."
    
    if ! command -v curl &> /dev/null; then
        print_warning "curl not found, skipping version check"
        return
    fi
    
    LATEST_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$LATEST_VERSION" ]; then
        print_warning "Could not determine the latest version. Continuing with $NVIM_VERSION."
    elif [ "$LATEST_VERSION" != "$NVIM_VERSION" ]; then
        print_warning "A newer version ($LATEST_VERSION) is available."
        read -p "Would you like to install the latest version instead? (y/n): " answer
        
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            NVIM_VERSION="$LATEST_VERSION"
            DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
            print_message "Will install version $NVIM_VERSION"
        else
            print_message "Continuing with version $NVIM_VERSION as specified"
        fi
    else
        print_success "You're installing the latest version ($NVIM_VERSION)"
    fi
}

# Main function
main() {
    print_message "Starting Neovim ${NVIM_VERSION} installation/update..."
    
    # Check for latest version
    check_latest_version
    
    # Download Neovim
    download_nvim
    
    # Make executable
    make_executable
    
    # Extract AppImage
    extract_appimage
    
    # Create symlink (no root needed now)
    create_symlink
    
    # Clean up
    print_message "Cleaning up..."
    rm -rf "$TEMP_DIR"
    
    print_success "Neovim ${NVIM_VERSION} has been successfully installed!"
    print_message "You can now run Neovim by typing 'nvim' in your terminal."
    
    # Add a note about PATH if needed
    if [[ ":$PATH:" != *":${HOME}/.local/bin:"* ]]; then
        print_warning "Remember to add ~/.local/bin to your PATH to use Neovim."
        print_message "Run this command or add it to your shell profile:"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    
    print_message "Your Neovim configuration is located at ${HOME}/.config/nvim"
}

# Run the main function
main

exit 0
