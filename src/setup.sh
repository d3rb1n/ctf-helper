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
    echo "  Usage: source $1 [options]"
    echo ""
    echo "Options:"
    echo "  --help      Shows this screen."
    echo "  --remove    Remove the current folder from the PATH if present."
}


# Check if the script was sourced
if [[ "$ZSH_EVAL_CONTEXT" == "toplevel:file" ]]; then
    print_msg info "Script was sourced, so new environment variables will take effect."
    WAS_SOURCED=true
else
    print_msg warning "Script was not sourced, so new environment variables will NOT automatically take effect. When done, please run:\n\n\tsource ~/.zshrc\n"
    WAS_SOURCED=false
fi

# Check if ~/.zshrc exists
if [ ! -f ~/.zshrc ]; then
    print_msg warning "No ~/.zshrc file found. These scripts are not meant for your current shell."
    [[ "$WAS_SOURCED" == true ]] && return || exit 1
fi

# Check if current folder is already in the PATH
CURRENT_FOLDER=$(pwd)
if grep -q "export PATH=\$PATH:$CURRENT_FOLDER" ~/.zshrc; then
    ALREADY_IN_PATH=true
else
    ALREADY_IN_PATH=false
fi

if [ "$1" = "--help" ]; then
    show_usage "$0"
    $WAS_SOURCED ? return : exit 0
elif [ "$1" = "--remove" ]; then
    if [ "$ALREADY_IN_PATH" = true ]; then
        sed -i "s|export PATH=\$PATH:$CURRENT_FOLDER||" ~/.zshrc
        sed -i '/^$/d' ~/.zshrc
        print_msg success "Removed current folder from PATH in ~/.zshrc."
    else
        print_msg info "Current folder is not in the PATH."
    fi
    [[ "$WAS_SOURCED" == true ]] && return || exit 0
fi

if [ "$ALREADY_IN_PATH" = false ]; then
    echo "export PATH=\$PATH:$CURRENT_FOLDER" >> ~/.zshrc
    print_msg success "Added current folder to PATH in ~/.zshrc."
else
    print_msg info "Current folder is already in the PATH."
fi

if [[ "$WAS_SOURCED" == true ]]; then

    print_msg info "Reloading .zshrc environment (~/.zshrc)"
    source ~/.zshrc

    if [ $? -ne 0 ]; then
        print_msg error "Failed to reload ~/.zshrc environment."
        success=false
    fi

fi