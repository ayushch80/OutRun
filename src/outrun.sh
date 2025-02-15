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
    msg "INFO" "Checking the system dependencies..."
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

    # Check if the out.run file already exists
    if [ -f "$proj/out.run" ]; then
        read -p "out.run exists. Overwrite? (y/N): " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 0
    fi

    # Start generating the template
    generate_template $proj
}

generate_template() {

    TEMPLATE_CONTENT="# OutRun configuration file\nOUTRUN_VERSION: \"$VERSION\""
    failCount=0 # Define fail count to prevent infinite loops
    failMax=3 # Limit for fail count

    pkgManagers=("npm" "yarn")

    proj=$1
    projName=''
    projRoot='./'
    projPkgManager=''

    # Ask for project name until it fails
    while [[ ! "$projName" =~ ^[a-z]+(-[a-z0-9]+)*$ ]]; do

        ((failCount == failMax)) && { msg "ALERT" "Too many invalid attempts. Exiting..."; exit 1; }
        ((failCount > 0)) && msg "ALERT" "Use kebab-case (e.g., 'my-project')."

        read -e -p "Project Name: " projName

        ((failCount++))
    done
    # Reset the fail count
    failCount=0
    # Append Project Name and Project Root to TEMPLATE_CONTENT
    TEMPLATE_CONTENT+="\n\nproj: \"$projName\""
    TEMPLATE_CONTENT+="\nroot: \"$projRoot\""

    # Ask for Project Package manager (only npm and yarn are supported)
    while [[ ! " ${pkgManagers[*]} " =~ " $projPkgManager " ]]; do

        ((failCount == failMax)) && { msg "ALERT" "Too many invalid attempts. Exiting..."; exit 1; }
        ((failCount > 0)) && msg "ALERT" "Only \"npm\" and \"yarn\" are supported."

        read -e -p "Package Manager (npm/yarn): " projPkgManager

        ((failCount++))
    done
    # Reset the fail count
    failCount=0
    # Append Project Name and Project Root to TEMPLATE_CONTENT
    TEMPLATE_CONTENT+="\nmanager: \"$projPkgManager\""


    # Save the template
    echo -e "$TEMPLATE_CONTENT" >"$proj/out.run"
    msg "SUCCESS" "[+] Template successfully generated."
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
