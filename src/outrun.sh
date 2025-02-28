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

# Tab Character
t="    " # Four spaces

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

    TEMPLATE_CONTENT="OUTRUN_VERSION: \"$VERSION\""

    pkgManagers=("npm")

    proj=$1
    projName=''
    projRoot='./'
    projPkgManager=''
    projPort='0'

    # cmd
    cmdDefault=''
    cmdBuild='npm run build'
    cmdStart='npm run start'

    prompt_until_valid() {
        prompt_message=$1
        validation_rule=$2
        error_message=$3
        variable=$4

        failCount=0 # Tracks the number of failed attempts
        failMax=3   # Maximum allowed failed attempts

        while ! eval $validation_rule; do
            ((failCount == failMax)) && {
                msg "ALERT" "Too many invalid attempts. Exiting..."
                exit 1
            }
            ((failCount > 0)) && { msg "ALERT" "$error_message"; }
            
            msg ""
            read -e -p "$prompt_message" "$variable"

            ((failCount++))
        done
    }

    prompt_until_valid "Project Name: " \
        '[[ "$projName" =~ ^[a-z]+(-[a-z0-9]+)*$ ]]' \
        "Invalid format. Use kebab-case (e.g., 'my-project')." \
        projName

    prompt_until_valid "Package Manager (npm): " \
        '[[ " ${pkgManagers[*]} " =~ " $projPkgManager " ]]' \
        "Invalid selection. Only \"npm\" is supported." \
        projPkgManager

    prompt_until_valid "Project Port: " \
        '[[ "$projPort" -ge 1024 && "$projPort" -le 49151 ]]' \
        "Invalid port. Choose a value between 1024 and 49151." \
        projPort

    read -e -p "Keep default commands? (Y/n): " cmdDefault
    msg ""
    cmdDefault=${cmdDefault,,}

    if [[ "$cmdDefault" == "y" || -z "$cmdDefault" ]]; then
        : # Eat 5 Star. Do Nothing.
    else
        read -e -p "Build command: " cmdBuild
        msg ""
        read -e -p "Start command: " cmdStart
        msg ""
    fi

    # Construct the Template
    TEMPLATE_CONTENT+="\n\nproj: \"$projName\""
    TEMPLATE_CONTENT+="\nroot: \"$projRoot\""
    TEMPLATE_CONTENT+="\nmanager: \"$projPkgManager\""
    TEMPLATE_CONTENT+="\nport: \"$projPort\""
    TEMPLATE_CONTENT+="\n\ncmd:"
    TEMPLATE_CONTENT+="\n${t}build: \"$cmdBuild\""
    TEMPLATE_CONTENT+="\n${t}start: \"$cmdStart\""

    TEMPLATE_CONTENT+="\n\n# OutRun configuration file"

    # Save the template
    echo -e "$TEMPLATE_CONTENT" >"$proj/out.run"
    msg "SUCCESS" "[+] Configuration file successfully created."
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
