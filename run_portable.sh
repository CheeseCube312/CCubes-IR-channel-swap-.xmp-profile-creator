#!/bin/bash

# XMP Profile Baker - Portable Edition for macOS/Linux
# Double-click this file to start the program

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[→]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Portable Python setup
PYTHON_DIR="$SCRIPT_DIR/python_portable"
PYTHON_EXE="$PYTHON_DIR/bin/python3"
PYTHON_VERSION="3.11.10"

echo "==============================================="
echo " XMP Profile Baker - Infrared Photography"
echo " Portable Edition - Cross-Platform Setup"
echo "==============================================="
echo

# Check if we're running on macOS and make sure the script has executable permissions
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Make this script executable if it isn't already
    if [[ ! -x "$0" ]]; then
        chmod +x "$0"
        print_info "Made script executable"
    fi
fi



# Simple portable Python installation
install_portable_python() {
    local os_type="$1"
    local arch="$2"
    
    print_info "Downloading portable Python (~20MB)..."
    
    mkdir -p "$PYTHON_DIR"
    
    local python_url=""
    if [[ "$os_type" == "darwin" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            python_url="https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10%2B20241016-aarch64-apple-darwin-install_only.tar.gz"
        else
            python_url="https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10%2B20241016-x86_64-apple-darwin-install_only.tar.gz"
        fi
    elif [[ "$os_type" == "linux" ]]; then
        if [[ "$arch" == "x86_64" ]]; then
            python_url="https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10%2B20241016-x86_64-unknown-linux-gnu-install_only.tar.gz"
        elif [[ "$arch" == "aarch64" ]]; then
            python_url="https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10%2B20241016-aarch64-unknown-linux-gnu-install_only.tar.gz"
        else
            return 1
        fi
    fi
    
    local temp_file="$SCRIPT_DIR/python_temp.tar.gz"
    
    # Download and extract
    if command -v curl &> /dev/null; then
        curl -L "$python_url" -o "$temp_file" --progress-bar && \
        tar -xzf "$temp_file" -C "$PYTHON_DIR" --strip-components=1 && \
        rm -f "$temp_file"
    elif command -v wget &> /dev/null; then
        wget "$python_url" -O "$temp_file" --progress=bar:force 2>/dev/null && \
        tar -xzf "$temp_file" -C "$PYTHON_DIR" --strip-components=1 && \
        rm -f "$temp_file"
    else
        print_error "Need curl or wget for download"
        return 1
    fi
    
    # Simple verification
    if [[ -f "$PYTHON_EXE" ]]; then
        return 0
    else
        return 1
    fi
}

# Check if portable Python exists
if [[ -f "$PYTHON_EXE" ]]; then
    print_status "Portable Python found - Starting program..."
    PYTHON_CMD="$PYTHON_EXE"
    # Skip to running the program
else
    print_info "No portable Python found - Setting up..."
    
    # Detect OS and architecture
    local os_type=""
    local arch=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="darwin"
        arch=$(uname -m)
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os_type="linux"
        arch=$(uname -m)
    else
        print_error "Automatic setup not supported on this platform"
        echo "Please install Python 3.6+ manually from https://www.python.org/downloads/"
        read -p "Press Enter to exit..."
        exit 1
    fi
    
    # Install portable Python (simplified)
    if install_portable_python "$os_type" "$arch"; then
        PYTHON_CMD="$PYTHON_EXE"
        print_status "Portable Python setup completed!"
    else
        print_error "Setup failed. Please install Python manually."
        read -p "Press Enter to exit..."
        exit 1
    fi
fi



# Check if the main Python file exists
MAIN_SCRIPT="$SCRIPT_DIR/xmp_profile_baker.py"
if [[ ! -f "$MAIN_SCRIPT" ]]; then
    print_error "Main script not found: $MAIN_SCRIPT"
    echo "Make sure all files are in the same directory."
    echo
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if source XMP files exist
SOURCE_DIR="$SCRIPT_DIR/source_xmp_files"
if [[ ! -d "$SOURCE_DIR" ]] || [[ -z "$(ls -A "$SOURCE_DIR"/*.xmp 2>/dev/null)" ]]; then
    print_warning "Source XMP files not found in: $SOURCE_DIR"
    echo "The program may not work correctly without source files."
fi

# Run the program
print_info "Starting XMP Profile Baker..."
echo

# Change to script directory to ensure relative paths work
cd "$SCRIPT_DIR"

# Run the Python program and capture exit code
$PYTHON_CMD "$MAIN_SCRIPT"
EXIT_CODE=$?

echo
if [[ $EXIT_CODE -eq 0 ]]; then
    print_status "Program completed successfully!"
else
    print_error "Program encountered an error"
    echo "Try running: $PYTHON_CMD xmp_profile_baker.py"
fi

echo
read -p "Press Enter to exit..."

exit $EXIT_CODE