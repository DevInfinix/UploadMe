#!/usr/bin/env bash
#
# Upload Files
#

# Config files
config() {
    local CONFIG_FILE="$1"
    local CONFIG_VAR="$2"
    local PROMPT="$3"

    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        read -p "$PROMPT" VALUE
        echo "$CONFIG_VAR=$VALUE" > "$CONFIG_FILE"
    fi
}

# Main menu options
echo " "

echo "
██╗   ██╗██████╗ ██╗      ██████╗  █████╗ ██████╗     ███╗   ███╗███████╗
██║   ██║██╔══██╗██║     ██╔═══██╗██╔══██╗██╔══██╗    ████╗ ████║██╔════╝
██║   ██║██████╔╝██║     ██║   ██║███████║██║  ██║    ██╔████╔██║█████╗  
██║   ██║██╔═══╝ ██║     ██║   ██║██╔══██║██║  ██║    ██║╚██╔╝██║██╔══╝  
╚██████╔╝██║     ███████╗╚██████╔╝██║  ██║██████╔╝    ██║ ╚═╝ ██║███████╗
 ╚═════╝ ╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝     ╚═╝     ╚═╝╚══════╝
"

echo "⭐ Star me on GitHub: https://github.com/DevInfinix/UploadMe"

echo " "

echo "[1] Github Release [gh auth login]
[2] Devuploads [Key]
[3] pixeldrain [Key]
[4] Temp.sh
[5] Gofile [Anonymous/Key]
[6] oshi.at
[7] Sourceforge [Key]
[8] Buzzheavier
"
echo "NOTE: This is a one-time setup. To reset, delete the respective .conf files in '~/' (your home directory)."

read -p "Please enter your number: " UP
read -p "Please enter file path/name: " FP

# Github upload
if [ "$UP" == "1" ]; then
    CONFIG_FILE="$HOME/.uploadme-github.conf"
    handle_config "$CONFIG_FILE" "GH" "Please enter Github repo link: "
    
    FN="$(basename $FP)" && FN="${FN%%.*}"
    echo -e "Started uploading file on Github..."
    gh release create "$FN" --generate-notes --repo "$GH"
    gh release upload --clobber "$FN" "$FP" --repo "$GH"

# Devuploads upload
elif [ "$UP" == "2" ]; then
    CONFIG_FILE="$HOME/.uploadme-devuploads.conf"
    handle_config "$CONFIG_FILE" "KEY" "Please enter DevUploads key: "
    
    echo -e "Started uploading file on DevUploads..."
    bash <(curl -s https://devuploads.com/upload.sh) -f "$FP" -k "$KEY"

# PixelDrain upload
elif [ "$UP" == "3" ]; then
    CONFIG_FILE="$HOME/.uploadme-pixeldrain.conf"
    handle_config "$CONFIG_FILE" "KEY" "Please enter PixelDrain key: "
    
    echo -e "Started uploading file on PixelDrain..."
    curl -T "$FP" -u ":$KEY" https://pixeldrain.com/api/file/

# Temp Upload
elif [ $UP == 4 ]; then
    echo -e "Started uploading file on Temp..."
    curl -T $FP temp.sh

# Gofile upload
elif [ "$UP" == "5" ]; then
    CONFIG_FILE="$HOME/.uploadme-gofile.conf"
    SERVER=$(curl -X GET 'https://api.gofile.io/servers' | grep -Po '(store*)[^"]*' | tail -n 1)

    echo "Choose upload type:"
    echo "[1] Anonymous upload"
    echo "[2] User upload (with Bearer token)"
    read -p "Enter your choice: " UPLOAD_TYPE

    if [ "$UPLOAD_TYPE" == "1" ]; then
        echo -e "Started anonymous upload on Gofile..."
        curl -X POST https://${SERVER}.gofile.io/contents/uploadfile -F "file=@$FP" | grep -Po '(https://gofile.io/d/)[^"]*'
    
    elif [ "$UPLOAD_TYPE" == "2" ]; then
        handle_config "$CONFIG_FILE" "BEARER_TOKEN" "Please enter your Bearer token: "
        
        echo -e "Started user upload on Gofile with Bearer token..."
        curl -X POST https://${SERVER}.gofile.io/contents/uploadfile -H "Authorization: Bearer $BEARER_TOKEN" -F "file=@$FP" | grep -Po '(https://gofile.io/d/)[^"]*'
    else
        echo "Invalid option selected."
    fi

elif [ $UP == 6 ]; then
    echo -e "Started uploading file on Oshi.at..."
    curl -T $FP https://oshi.at

elif [ $UP == 7 ]; then
    echo -e "Started uploading file on Sourceforge..."
    read -p "Please enter Username: " USER
    read -p "Please enter upload location:
    Note: Path after /home/frs/project/" UPL
    scp $FP "$USER"@frs.sourceforge.net:/home/frs/project/$UPL

elif [ $UP == 8 ]; then
    FN="$(basename $FP)"
    echo -e "Started uploading $FN on Buzzheavier..."
    BZUP=https://buzzheavier.com/f/$(curl -#o - -T "$FP" https://w.buzzheavier.com/t/$FN | cut -d : -f 2 | cut -d } -f 1 | grep -Po '[^"]*')
    echo $BZUP
else
    echo "Invalid option: Please select a valid option (1-8)"
fi