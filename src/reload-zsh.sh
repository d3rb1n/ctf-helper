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

# Check if the script was sourced
if [[ "$ZSH_EVAL_CONTEXT" == "toplevel:file" ]]; then
    print_msg info "Script was sourced, so shell can be reloaded."
    
    print_msg info "Reloading .zshrc environment (~/.zshrc)"
    source ~/.zshrc

    if [ $? -ne 0 ]; then
        print_msg error "Failed to .zshrc environment."
        success=false
    fi
else
    print_msg error "Script was not sourced, so environment cannot be reloaded. Run with "." or "source" prefix, or manually run:\n\n\tsource ~/.zshrc\n"
fi
