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

    echo "Create a new write-up directory with template files for a CTF room."
    echo ""
    echo "  Usage: source $0 <platform> <room_name>"
    echo ""
    echo "Arguments:"
    echo "  platform   Should be an acronym for a CTF platform like: \"thm\" for TryHackMe, or \"htb\" for HackTheBox, etc."
    echo "  room_name  Should be the name of the \"room\" on the CTF platform, which is usually the last part of the URL."
    echo ""
    echo "Set CTF_HOME to the root folder to use, otherwise $HOME/ctf/ is used."
}

# Check if the script was sourced
if [[ "$ZSH_EVAL_CONTEXT" == "toplevel:file" ]]; then
    print_msg info "Script was sourced, so new environment variables will take effect."
    WAS_SOURCED=true
else
    print_msg warning "Script was not sourced, so new environment variables will NOT automatically take effect. When done, please run:\n\n\tsource ~/.zshrc\n"
    WAS_SOURCED=false
fi

# Check for arguments
if [ $# -eq 0 ]; then
    show_usage
    [[ "$WAS_SOURCED" == true ]] && return || exit 1
fi

# Handle help argument
if [ "$1" = "--help" ]; then
    show_usage
    [[ "$WAS_SOURCED" == true ]] && return || exit 0
fi

if [ $# -ne 2 ]; then
    show_usage
    [[ "$WAS_SOURCED" == true ]] && return || exit 1
fi

PLATFORM=$1
ROOM_NAME=$2

if [ -n "$CTF_HOME" ]; then
    ROOM_PATH="$CTF_HOME/$PLATFORM/$ROOM_NAME"
else
    ROOM_PATH="$HOME/ctf/$PLATFORM/$ROOM_NAME"
fi


SCRIPT_DIR="$(dirname "$0")"

# Initialize a variable to track success
success=true

print_msg info "STEP 1: Create the directory if it doesn't exist: $ROOM_PATH"
mkdir -p "$ROOM_PATH"
if [ $? -ne 0 ]; then
    print_msg error "Failed to create directory: $ROOM_PATH"
    success=false
fi

if [ "$success" = true ]; then
    print_msg info "STEP 2: Setting ROOM environment variable in ~/.zshrc"

    export_statement="export ROOM=${ROOM_PATH}"
    zshrc_file=~/.zshrc

    if ! grep -qF "$export_statement" $zshrc_file; then
        echo "$export_statement" >> $zshrc_file
        print_msg success "ROOM export statement added to: $zshrc_file"
    else
        sed -i "s|export ROOM=.*|${export_statement}|" $zshrc_file
        print_msg success "ROOM export statement updated in: $zshrc_file"
    fi

    if ! grep -q "export ROOM" ~/.zshrc; then
        print_msg error "Failed to set ROOM environment variable"
        success=false
    fi
fi

if [ "$success" = true ]; then
    print_msg info "STEP 3: Copy files from _TemplateRoom to: $ROOM_PATH"
    cp -r ${SCRIPT_DIR}/_TemplateRoom/* "$ROOM_PATH"
    if [ $? -ne 0 ]; then
        print_msg error "Failed to copy files to $ROOM_PATH"
        success=false
    else
        mv "${ROOM_PATH}/_Template.md" "${ROOM_PATH}/index.md"
    fi
fi

if [ "$success" = true ]; then
    print_msg info "STEP 4: Search and replace %ROOM% in files"
    for file in "$ROOM_PATH"/*; do
        if [ -f "$file" ]; then
            sed -i "s/%ROOM%/${ROOM_NAME}/g" "$file"
            if [ $? -ne 0 ]; then
                print_msg error "Failed to replace %ROOM% in $file"
                success=false
                break
            fi
        fi
    done
fi

if [ "$success" = true ]; then
    print_msg info "STEP 5: Changing directory to $ROOM_PATH"
    cd "$ROOM_PATH" || { print_msg error "Failed to switch to $ROOM_PATH"; exit 1; }
    if [ $? -ne 0 ]; then
        print_msg error "Failed to switch to $ROOM_PATH"
        success=false
    fi
fi

if [[ "$success" == true && "$WAS_SOURCED" == true ]]; then

    print_msg info "STEP 6: Reloading .zshrc environment (${zshrc_file})"
    source ${zshrc_file}

    if [ $? -ne 0 ]; then
        print_msg error "Failed to .zshrc environment."
        success=false
    fi

fi

if [ "$success" = true ]; then
    print_msg success "All steps completed successfully"
else
    print_msg error "Script encountered errors, some steps might have been undone"
fi
