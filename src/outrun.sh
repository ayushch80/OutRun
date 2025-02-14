VERSION="1.0.0"

# Print ASCII Art
echo -e "
\033[38;2;255;0;0m      ▄• ▄▌▄▄▄▄▄▄▄▄  ▄• ▄▌ ▐ ▄ \033[0m
\033[38;2;230;0;0m▪     █▪██▌•██  ▀▄ █·█▪██▌•█▌▐█\033[0m
\033[38;2;205;0;0m ▄█▀▄ █▌▐█▌ ▐█.▪▐▀▀▄ █▌▐█▌▐█▐▐▌\033[0m
\033[38;2;180;0;0m▐█▌.▐▌▐█▄█▌ ▐█▌·▐█•█▌▐█▄█▌██▐█▌\033[0m
\033[38;2;155;0;0m ▀█▄▀▪ ▀▀▀  ▀▀▀ .▀  ▀ ▀▀▀ ▀▀ █▪\033[0m
"

# Capture CLI Arguments
command=$1
parameter=$2

# Available Commands:
# 1. help              - Show available commands
# 2. version           - Display the current version
# 3. init [path]       - Initialize an OutRun project (default: current directory)

# Define Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
RESET='\e[0m'

# Function to Display Messages with Colors
msg() {
    case $1 in
    "SUCCESS") echo -e "${GREEN}$2${RESET}" ;;
    "ERROR") echo -e "${RED}$2${RESET}" ;;
    "ALERT") echo -e "${YELLOW}$2${RESET}" ;;
    "INFO") echo -e "${BLUE}$2${RESET}" ;;
    *) echo -e "$1" ;;
    esac
}

# Function to Check for Required Packages
check_package() {
    if ! command -v "$1" &>/dev/null; then
        msg "ERROR" "[-] Missing: $1"
        exit 1
    else
        msg "SUCCESS" "[+] Found: $1"
    fi
}

# Verify All Required Packages
check_required_packages() {
    msg "INFO" "Checking system dependencies..."
    check_package "cloudflared"
    check_package "yq"
    check_package "npm"
    check_package "node"
    msg ""
}

# Display Help Menu
help() {
    msg "${CYAN}OutRun v$VERSION${RESET}"
    msg ""
    msg "${MAGENTA}Available Commands:${RESET}"
    msg "  help              Show this help message"
    msg "  version           Display the OutRun version"
    msg "  init [path]       Initialize an OutRun project (default: current directory)"
    msg ""
}

# Show Version
version() {
    msg "OutRun v$VERSION"
}

# Initialize an OutRun Project
init() {
    # Set project path, defaulting to the current directory if none is provided
    proj=$(realpath "${parameter:-.}")

    msg "INFO" "Initializing OutRun project at: $proj"

    # Define the out.run template
    TEMPLATE_CONTENT="OUTRUN_VERSION: \"$VERSION\"\n# OutRun configuration file"

    # Check if the out.run file already exists
    if [ -f "$proj/out.run" ]; then
        msg "ALERT" "An 'out.run' file already exists at $proj."

        # Ask for confirmation to overwrite
        read -p "Do you want to overwrite it? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "$TEMPLATE_CONTENT" >"$proj/out.run"
            msg "SUCCESS" "out.run file overwritten successfully."
        else
            msg "INFO" "Operation canceled. Keeping the existing 'out.run' file."
            exit 0
        fi
    else
        # Create a new out.run file if it doesn't exist
        echo -e "$TEMPLATE_CONTENT" >"$proj/out.run"
        msg "SUCCESS" "out.run file created successfully."
    fi
}

# Command Execution Logic
case $command in
"help" | "")
    help
    ;;
"version")
    version
    ;;
"init")
    init
    ;;
*)
    msg "ERROR" "Invalid command. Run 'outrun help' for usage."
    exit 1
    ;;
esac
