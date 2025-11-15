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
    
    # Download and extract with verification
    local download_success=false
    
    if command -v curl &> /dev/null; then
        print_info "Using curl for download..."
        if curl -L "$python_url" -o "$temp_file" --progress-bar --connect-timeout 30 --max-time 300; then
            download_success=true
        fi
    elif command -v wget &> /dev/null; then
        print_info "Using wget for download..."
        if wget "$python_url" -O "$temp_file" --progress=bar:force --timeout=30 --tries=3 2>/dev/null; then
            download_success=true
        fi
    else
        print_error "Need curl or wget for download"
        return 1
    fi
    
    # Verify download was successful
    if [[ "$download_success" == false ]] || [[ ! -f "$temp_file" ]] || [[ ! -s "$temp_file" ]]; then
        print_error "Download failed or file is empty"
        rm -f "$temp_file"
        return 1
    fi
    
    print_info "Download completed, extracting..."
    
    # Extract with error checking
    if tar -xzf "$temp_file" -C "$PYTHON_DIR" --strip-components=1; then
        rm -f "$temp_file"
        print_status "Extraction completed"
    else
        print_error "Extraction failed"
        rm -f "$temp_file"
        return 1
    fi
    
    # Comprehensive verification
    if [[ ! -f "$PYTHON_EXE" ]]; then
        print_error "Python executable not found after installation"
        return 1
    fi
    
    # Test Python functionality
    print_info "Testing Python installation..."
    
    # Test basic Python execution
    if ! "$PYTHON_EXE" -c "print('Python works')" &>/dev/null; then
        print_error "Python installation failed - basic execution test failed"
        return 1
    fi
    
    # Test tkinter availability (critical for GUI)
    if ! "$PYTHON_EXE" -c "import tkinter; print('tkinter available')" &>/dev/null; then
        print_error "Python installation failed - tkinter not available"
        print_error "GUI applications will not work without tkinter"
        return 1
    fi
    
    print_status "Python installation verified successfully"
    return 0
}

# Check if portable Python exists and is functional
if [[ -f "$PYTHON_EXE" ]]; then
    print_info "Checking existing Python installation..."
    
    # Test if existing Python actually works
    if "$PYTHON_EXE" -c "import sys, tkinter; print(f'Python {sys.version} with tkinter ready')" &>/dev/null; then
        print_status "Portable Python found and functional - Starting program..."
        PYTHON_CMD="$PYTHON_EXE"
        # Skip to running the program
    else
        print_warning "Found Python installation but it's not functional"
        print_info "Reinstalling portable Python..."
        rm -rf "$PYTHON_DIR"
        # Continue to installation
    fi
fi

if [[ ! -f "$PYTHON_EXE" ]]; then
    print_info "No portable Python found - Setting up..."
    
    # Detect OS and architecture
    os_type=""
    arch=""
    
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
    
    # Install portable Python with timeout and retry
    print_info "Installing portable Python (this may take a few minutes)..."
    
    # Give installation some time to complete
    if timeout 600 bash -c 'install_portable_python "'$os_type'" "'$arch'"' 2>/dev/null || install_portable_python "$os_type" "$arch"; then
        PYTHON_CMD="$PYTHON_EXE"
        print_status "Portable Python setup completed!"
        
        # Wait a moment for file system to catch up
        sleep 2
        
        # Final verification that Python actually works
        if ! "$PYTHON_CMD" -c "import sys; print(f'Python {sys.version} ready')" &>/dev/null; then
            print_error "Installation completed but Python is not functional"
            print_error "Try running the script again or install Python manually"
            read -p "Press Enter to exit..."
            exit 1
        fi
    else
        print_error "Setup failed. Please install Python manually from https://www.python.org/downloads/"
        print_error "Make sure Python 3.6+ with tkinter is installed"
        read -p "Press Enter to exit..."
        exit 1
    fi
fi



# Final verification before running
print_info "Performing final checks..."

# Verify Python is still working
if ! "$PYTHON_CMD" -c "print('Final Python check passed')" &>/dev/null; then
    print_error "Python installation became non-functional"
    print_error "Try running the script again or install Python manually"
    read -p "Press Enter to exit..."
    exit 1
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
    echo "Output files should be available in the 'output' directory."
else
    print_error "Program encountered an error (Exit code: $EXIT_CODE)"
    echo "Manual command to try: $PYTHON_CMD xmp_profile_baker.py"
    echo "Make sure all source XMP files are present in 'source_xmp_files' directory."
    echo
    print_info "Troubleshooting tips:"
    echo "1. Make sure all source XMP files exist"
    echo "2. Check that you have write permissions in the script directory"
    echo "3. Ensure no antivirus software is blocking the program"
fi

echo
read -p "Press Enter to exit..."

exit $EXIT_CODE