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

# Function to check if Python is available and get version
check_python() {
    local python_cmd="$1"
    if command -v "$python_cmd" &> /dev/null; then
        local version=$($python_cmd --version 2>&1 | cut -d' ' -f2)
        local major=$(echo $version | cut -d'.' -f1)
        local minor=$(echo $version | cut -d'.' -f2)
        
        # Check if Python version is 3.6 or higher
        if [[ $major -eq 3 && $minor -ge 6 ]] || [[ $major -gt 3 ]]; then
            echo "$python_cmd"
            return 0
        fi
    fi
    return 1
}

# Function to download and install portable Python
install_portable_python() {
    local os_type="$1"
    local arch="$2"
    
    print_info "Setting up portable Python environment..."
    echo "    This is a one-time setup, please wait..."
    
    # Create python directory
    mkdir -p "$PYTHON_DIR"
    
    local python_url=""
    local python_file=""
    local extract_method=""
    
    # Use Python standalone builds from indygreg/python-build-standalone
    # These are truly portable and don't require system installation
    if [[ "$os_type" == "darwin" ]]; then
        if [[ "$arch" == "arm64" ]]; then
            python_url="https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10%2B20241016-aarch64-apple-darwin-install_only.tar.gz"
        else
            python_url="https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10%2B20241016-x86_64-apple-darwin-install_only.tar.gz"
        fi
        python_file="python-portable-macos.tar.gz"
        extract_method="tar"
        
    elif [[ "$os_type" == "linux" ]]; then
        if [[ "$arch" == "x86_64" ]]; then
            python_url="https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10%2B20241016-x86_64-unknown-linux-gnu-install_only.tar.gz"
        elif [[ "$arch" == "aarch64" ]]; then
            python_url="https://github.com/indygreg/python-build-standalone/releases/download/20241016/cpython-3.11.10%2B20241016-aarch64-unknown-linux-gnu-install_only.tar.gz"
        else
            print_error "Unsupported Linux architecture: $arch"
            return 1
        fi
        python_file="python-portable-linux.tar.gz"
        extract_method="tar"
    fi
    
    if [[ -z "$python_url" ]]; then
        print_error "Automatic Python installation not supported for this platform"
        return 1
    fi
    
    print_info "Downloading portable Python ${PYTHON_VERSION} (~20MB)..."
    local temp_file="$SCRIPT_DIR/$python_file"
    
    # Download Python
    if command -v curl &> /dev/null; then
        if ! curl -L "$python_url" -o "$temp_file" --progress-bar; then
            print_error "Download failed with curl"
            return 1
        fi
    elif command -v wget &> /dev/null; then
        if ! wget "$python_url" -O "$temp_file" --progress=bar:force 2>/dev/null; then
            print_error "Download failed with wget"
            return 1
        fi
    else
        print_error "Neither curl nor wget found. Cannot download Python automatically."
        print_info "Please install curl or wget, or manually install Python 3.6+"
        return 1
    fi
    
    if [[ ! -f "$temp_file" ]]; then
        print_error "Download failed - file not found!"
        return 1
    fi
    
    print_info "Extracting portable Python..."
    
    # Extract the portable Python
    if [[ "$extract_method" == "tar" ]]; then
        if ! tar -xzf "$temp_file" -C "$PYTHON_DIR" --strip-components=1; then
            print_error "Extraction failed!"
            rm -f "$temp_file"
            return 1
        fi
    fi
    
    # Clean up download file
    rm -f "$temp_file"
    
    # Verify installation
    if [[ ! -f "$PYTHON_EXE" ]]; then
        print_error "Python installation verification failed"
        print_error "Expected Python at: $PYTHON_EXE"
        return 1
    fi
    
    # Test if Python works
    if ! "$PYTHON_EXE" --version &>/dev/null; then
        print_error "Installed Python is not working properly"
        return 1
    fi
    
    print_status "Portable Python setup completed successfully!"
    return 0
}

# Check if portable Python exists first
if [[ -f "$PYTHON_EXE" ]]; then
    print_status "Portable Python found - Starting program..."
    PYTHON_CMD="$PYTHON_EXE"
else
    # Try to find a suitable system Python installation first
    print_info "Checking for system Python installation..."
    
    PYTHON_CMD=""
    for cmd in python3 python python3.11 python3.10 python3.9 python3.8 python3.7 python3.6; do
        if PYTHON_CMD=$(check_python "$cmd"); then
            break
        fi
    done
    
    if [[ -n "$PYTHON_CMD" ]]; then
        python_version=$($PYTHON_CMD --version 2>&1)
        print_status "Found system Python: $python_version using command: $PYTHON_CMD"
    else
        print_warning "No system Python installation found"
        echo
        
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
            print_error "Automatic Python installation not supported on this platform"
            echo
            echo "Please manually install Python 3.6 or higher:"
            echo "• Download from: https://www.python.org/downloads/"
            echo
            read -p "Press Enter to exit..."
            exit 1
        fi
        
        print_info "Setting up portable Python for $os_type ($arch)..."
        
        # Install portable Python
        if install_portable_python "$os_type" "$arch"; then
            PYTHON_CMD="$PYTHON_EXE"
            python_version=$($PYTHON_CMD --version 2>&1)
            print_status "Portable Python ready: $python_version"
        else
            print_error "Failed to set up portable Python"
            echo
            echo "Please manually install Python 3.6 or higher:"
            if [[ "$os_type" == "darwin" ]]; then
                echo "• Download from: https://www.python.org/downloads/"
                echo "• Or install via Homebrew: brew install python3"
            elif [[ "$os_type" == "linux" ]]; then
                echo "• Ubuntu/Debian: sudo apt install python3 python3-tk"
                echo "• CentOS/RHEL/Fedora: sudo yum install python3 python3-tkinter"
            fi
            echo
            read -p "Press Enter to exit..."
            exit 1
        fi
    fi
fi

# Check if tkinter is available
print_info "Checking GUI support (tkinter)..."
if $PYTHON_CMD -c "import tkinter" &> /dev/null; then
    print_status "GUI support (tkinter) is available"
else
    print_error "tkinter not found! GUI will not work."
    echo
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "On macOS, tkinter should be included with Python."
        echo "Try reinstalling Python from python.org or using Homebrew."
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Install tkinter:"
        echo "• Ubuntu/Debian: sudo apt install python3-tk"
        echo "• CentOS/RHEL: sudo yum install python3-tkinter"
        echo "• Fedora: sudo dnf install python3-tkinter"
    fi
    echo
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
else
    print_error "Program encountered an error (exit code: $EXIT_CODE)"
    echo
    echo "Troubleshooting:"
    echo "• Make sure all files are in the same directory"
    echo "• Check that you have the necessary permissions"
    echo "• Ensure Adobe Lightroom is installed (for automatic file placement)"
    echo "• Try running the Python file directly: $PYTHON_CMD xmp_profile_baker.py"
fi

echo
read -p "Press Enter to exit..."

exit $EXIT_CODE