#!/usr/bin/env bash
#
# Name: UploadMe - Revamped Upload Scripts
# Author: DevInfinix
# Forked From: https://github.com/1xtAsh/MyScripts
#

# Color definitions
G="\033[32m"  # Green
B="\033[34m"  # Blue
R="\033[31m"  # Red
C="\033[36m"  # Cyan
M="\033[35m"  # Magenta
RESET="\033[0m"  # Reset color

print_color() {
    local color="$1"
    shift
    echo -e "${color}$*${RESET}"
}


# Config files
config() {
    local CONFIG_FILE="$1"
    local CONFIG_VAR="$2"
    local PROMPT="$3"

    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        read -p "$PROMPT" VALUE
        print_color "$G" "$CONFIG_VAR=$VALUE" > "$CONFIG_FILE"
    fi
}


# Check if file exists
check_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        print_color "$R" "Error: File '$file' does not exist."
        exit 1
    fi
}


# Quit
quit_program() {
    print_color "$R" "Exiting the program. Goodbye!"
    exit 0
}


# Main menu options
echo " "

print_color "$C" "
██╗   ██╗██████╗ ██╗      ██████╗  █████╗ ██████╗     ███╗   ███╗███████╗
██║   ██║██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗    ████╗ ████║██╔════╝
██║   ██║██████╔╝██║     ██║   ██║███████║██║  ██║    ██╔████╔██║█████╗  
██║   ██║██╔═══╝ ██║     ██║   ██║██╔══██║██║  ██║    ██║╚██╔╝██║██╔══╝  
╚██████╔╝██║     ███████╗╚██████╔╝██║  ██║██████╔╝    ██║ ╚═╝ ██║███████╗
 ╚═════╝ ╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝     ╚═╝     ╚═╝╚══════╝
"

print_color "$M" "⭐ Star me on GitHub: https://github.com/DevInfinix/UploadMe"

echo " "

print_color "$B" "[1] Github Release [gh auth login]
[2] Devuploads [Key]
[3] pixeldrain [Key]
[4] Temp.sh
[5] Gofile [Anonymous/Key]
[6] oshi.at
[7] Sourceforge [Key]
[8] Buzzheavier
[9] Quit
"
print_color "$R" "NOTE: This is a one-time setup. To reset, delete the respective .conf files in '~/' (your home directory)."


if [ "$UP" == "9" ]; then
    quit_program
fi


read -p "Please enter your number: " UP
read -p "Please enter file path/name: " FP

check_file_exists "$FP"


# Github upload
if [ "$UP" == "1" ]; then
    CONFIG_FILE="$HOME/.uploadme-github.conf"
    handle_config "$CONFIG_FILE" "GH" "Please enter Github repo link: "
    
    FN="$(basename $FP)" && FN="${FN%%.*}"
    print_color "$G" -e "Started uploading file on Github..."
    gh release create "$FN" --generate-notes --repo "$GH"
    gh release upload --clobber "$FN" "$FP" --repo "$GH"


# Devuploads upload
elif [ "$UP" == "2" ]; then
    CONFIG_FILE="$HOME/.uploadme-devuploads.conf"
    handle_config "$CONFIG_FILE" "KEY" "Please enter DevUploads key: "
    
    print_color "$G" -e "Started uploading file on DevUploads..."
    bash <(curl -s https://devuploads.com/upload.sh) -f "$FP" -k "$KEY"


# PixelDrain upload
elif [ "$UP" == "3" ]; then
    CONFIG_FILE="$HOME/.uploadme-pixeldrain.conf"
    handle_config "$CONFIG_FILE" "KEY" "Please enter PixelDrain key: "
    
    print_color "$G" -e "Started uploading file on PixelDrain..."
    curl -T "$FP" -u ":$KEY" https://pixeldrain.com/api/file/


# Temp Upload
elif [ $UP == 4 ]; then
    print_color "$G" -e "Started uploading file on Temp..."
    curl -T $FP temp.sh


# Gofile upload
elif [ "$UP" == "5" ]; then
    CONFIG_FILE="$HOME/.uploadme-gofile.conf"
    print_color "$M" "Choose upload type:"
    print_color "$M" "[1] Anonymous upload"
    print_color "$M" "[2] User upload (with Bearer token)"
    read -p "Enter your choice: " UPLOAD_TYPE

    if [ "$UPLOAD_TYPE" == "1" ]; then
        print_color "$G" -e "Started anonymous upload on Gofile..."
        SERVER=$(curl -X GET 'https://api.gofile.io/servers' | grep -Po '(store*)[^"]*' | tail -n 1)
        curl -X POST https://${SERVER}.gofile.io/contents/uploadfile -F "file=@$FP" | grep -Po '(https://gofile.io/d/)[^"]*'
    
    elif [ "$UPLOAD_TYPE" == "2" ]; then
        handle_config "$CONFIG_FILE" "BEARER_TOKEN" "Please enter your Bearer token: "
        SERVER=$(curl -X GET 'https://api.gofile.io/servers' | grep -Po '(store*)[^"]*' | tail -n 1)
        print_color "$G" -e "Started user upload on Gofile with Bearer token..."
        curl -X POST https://${SERVER}.gofile.io/contents/uploadfile -H "Authorization: Bearer $BEARER_TOKEN" -F "file=@$FP" | grep -Po '(https://gofile.io/d/)[^"]*'
    else
        print_color "$R" "Invalid option selected."
    fi


elif [ $UP == 6 ]; then
    print_color "$G" -e "Started uploading file on Oshi.at..."
    curl -T $FP https://oshi.at


elif [ $UP == 7 ]; then
    print_color "$G" -e "Started uploading file on Sourceforge..."
    read -p "Please enter Username: " USER
    read -p "Please enter upload location:
    Note: Path after /home/frs/project/" UPL
    scp $FP "$USER"@frs.sourceforge.net:/home/frs/project/$UPL


elif [ $UP == 8 ]; then
    FN="$(basename $FP)"
    print_color "$C" -e "Started uploading $FN on Buzzheavier..."
    BZUP=https://buzzheavier.com/f/$(curl -#o - -T "$FP" https://w.buzzheavier.com/t/$FN | cut -d : -f 2 | cut -d } -f 1 | grep -Po '[^"]*')
    print_color "$G" $BZUP


else
    print_color "$R" "Invalid option: Please select a valid option (1-8)"
fi