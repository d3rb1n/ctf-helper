#!/bin/zsh

# Define color codes for messages
Black='\033[0;30m'
DarkGray='\033[1;30m'
Red='\033[0;31m'
LightRed='\033[1;31m'
Green='\033[0;32m'
LightGreen='\033[1;32m'
Brown='\033[0;33m'
Yellow='\033[1;33m'
Blue='\033[0;34m'
LightBlue='\033[1;34m'
Purple='\033[0;35m'
LightPurple='\033[1;35m'
Cyan='\033[0;36m'
LightCyan='\033[1;36m'
LightGray='\033[0;37m'
White='\033[1;37m'
NC='\033[0m' # No Color

function print_msg(){

    description=$2
    severity=$1

    case "$severity" in
        "success")
            echo -e "[${LightGreen}+${NC}] ${LightGreen}${description}${NC}"
        ;;
        "error")
            echo -e "[${Red}-${NC}] ${LightRed}${description}${NC}"
        ;;
        "warning")
            echo -e "[${Yellow}!${NC}] ${Yellow}${description}${NC}"
        ;;
        "info")
            echo -e "[${LightCyan}*${NC}] ${LightCyan}${description}${NC}"
        ;;
    esac
}

function show_usage() {
    echo "Installs or uninstalls Discord, because the regular .deb way is broken."
    echo ""
    echo "  Usage: $0 [ --install | --uninstall | --help ]"
    echo ""
    echo "Arguments:"
    echo "  --help      Shows this screen."
    echo "  --install   Installs Discord and adds an app icon to the XFCE main menu."
    echo "  --uninstall Uninstalls Discord and removes the XFCE mail menu icon."
}

function check_root() {
    if [[ $(id -u) -ne 0 ]]; then
        print_msg "error" "This script must be run as root or with sudo."
        exit 1
    fi
}

if [[ -n "$SUDO_USER" ]]; then
    print_msg "info" "This command was run as root by $SUDO_USER."
    HOME_PATH=/home/$SUDO_USER
else
    print_msg "info" "This command was not run with sudo."
    HOME_PATH=/root
fi

function run_command() {
    local cmd="$1"
    local success_msg="$2"
    local error_msg="$3"

    eval "$cmd"
    local exit_status=$?

    if [[ $exit_status -eq 0 ]]; then
        print_msg "success" "$success_msg"
    else
        print_msg "error" "$error_msg"
        exit 1
    fi
}

function install_discord() {

    print_msg "info" "Checking if a download of: ${HOME_PATH}/Downloads/discord.tar.gz exists..."
    if [[ -e "${HOME_PATH}/Downloads/discord.tar.gz" ]]; then
        print_msg "warning" "Does exist. Deleting file because Discord is always updating; always download the latest."
        rm -f "${HOME_PATH}/Downloads/discord.tar.gz"
    fi

    print_msg "info" "Downloading Discord tar.gz file to: ${HOME_PATH}/Downloads/..."
    run_command "wget -O ${HOME_PATH}/Downloads/discord.tar.gz 'https://discord.com/api/download?platform=linux&format=tar.gz'" \
        "Downloaded Discord to: ${HOME_PATH}/Downloads/discord.tar.gz" \
        "Failed to download Discord."

    print_msg "info" "Unpacking tar file..."
    run_command "mkdir -p ${HOME_PATH}/Downloads/Discord/ && tar zxf ${HOME_PATH}/Downloads/discord.tar.gz -C ${HOME_PATH}/Downloads/Discord/" \
        "Unpacked Discord to: ${HOME_PATH}/Downloads/Discord/" \
        "Failed to unpack Discord."

    print_msg "info" "Creating the destination folder for the executable..."
    if [[ -d "/usr/share/discord" ]]; then
            print_msg "warning" "The destination folder for the executable already exists."
        else    
            run_command "mkdir -p /usr/share/discord" \
                "Created the destination folder for the executable" \
                "Failed to create the destination folder"
    fi

    print_msg "info" "Copy the executable and supporting files to: /usr/share/discord/..."
    run_command "cp -R ${HOME_PATH}/Downloads/Discord/Discord/* /usr/share/discord/" \
        "Copied Discord files to /usr/share/discord/" \
        "Failed to copy Discord files"

    print_msg "info" "Copy the XFCE menu item file to: /usr/share/applications/..."
    run_command "cp ${HOME_PATH}/Downloads/Discord/Discord/discord.desktop /usr/share/applications/" \
        "Copied the .desktop file for all users" \
        "Failed to copy the .desktop file"
    
    print_msg "success" "Installation completed successfully"
}

function uninstall_discord() {
    print_msg "info" "Removing Discord files and directories"

    run_command "rm -rf /usr/share/discord/ /usr/share/applications/discord.desktop" \
        "Removed Discord files and directories" \
        "Failed to remove Discord files and directories"
    
    print_msg "success" "Uninstallation completed successfully."
}

if [ "$#" -ne 1 ]; then
    show_usage
    exit 1
fi

case "$1" in
    "--install")
        check_root
        install_discord
        ;;
    "--uninstall")
        check_root
        uninstall_discord
        ;;
    "--help")
        show_usage
        ;;
    *)
        show_usage
        exit 1
        ;;
esac

exit 0
