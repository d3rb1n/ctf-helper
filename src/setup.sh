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
            echo -e "[${Red}-${NC}] ${Red}${description}${NC}"
        ;;
        "warning")
            echo -e "[${Yellow}?${NC}] ${Yellow}${description}${NC}"
        ;;
        "info")
            echo -e "[${LightCyan}*${NC}] ${LightCyan}${description}${NC}"
        ;;
    esac
}

function show_usage() {
    echo "Adds this tool directory to the PATH if it doesn't already exist."
    echo ""
    echo "  Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --help      Shows this screen."
    echo "  --remove    Remove the current folder from the PATH if present."
}

# if [ $# -eq 0 ]; then
#     show_usage
#     exit 0
# fi

# Check if ~/.zshrc exists
if [ ! -f ~/.zshrc ]; then
    print_msg warning "No ~/.zshrc file found. These scripts are not meant for your current shell."
    exit 1
fi

# Check if current folder is already in the PATH
CURRENT_FOLDER=$(pwd)
if grep -q "export PATH=\$PATH:$CURRENT_FOLDER" ~/.zshrc; then
    ALREADY_IN_PATH=true
else
    ALREADY_IN_PATH=false
fi

if [ "$1" = "--help" ]; then
    show_usage
    exit 0
elif [ "$1" = "--remove" ]; then
    if [ "$ALREADY_IN_PATH" = true ]; then
        sed -i "s|export PATH=\$PATH:$CURRENT_FOLDER||" ~/.zshrc
        sed -i '/^$/d' ~/.zshrc
        print_msg success "Removed current folder from PATH in ~/.zshrc."
        print_msg info "Please run the following command to reload your environment:"
        echo ""
        echo "  source ~/.zshrc"        
    else
        print_msg info "Current folder is not in the PATH."
    fi
    exit 0
fi

if [ "$ALREADY_IN_PATH" = false ]; then
    echo "export PATH=\$PATH:$CURRENT_FOLDER" >> ~/.zshrc
    print_msg success "Added current folder to PATH in ~/.zshrc."
    print_msg info "Please run the following command to reload your environment:"
    echo ""
    echo "  source ~/.zshrc"
else
    print_msg info "Current folder is already in the PATH."
fi