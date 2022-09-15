#!/bin/sh

# Setup 
DUMP_FILE="card.dump"

if [ -e "output" ]; then
    rm "output"
fi

# Function definitions
function help() {
    echo "F-nc - F-klubben POC NFC tool"
    echo ""
    echo "f-nc OPTION"
    echo ""
    echo "      r KEY [DUMP_FILE]  - KEY decryption keys. DUMP_FILE card dump file (Default: $DUMP_FILE)"
    echo "      w DUMP_FILE        - DUMP_FILE card dump file (Default: $DUMP_FILE)"
}

function readtag() {
    if [ -z "$2" ]; then # no key supplied probably
        KEY=""
        DUMP_FILE="$1"
    else
        KEY="$1"
        DUMP_FILE="$2"
    fi

    if [ "$(which mfoc)" = "mfoc not found" ]; then
        echo "You do not have MFOC installed. Please go to https://github.com/nfc-tools/mfoc"
        exit 1
    fi
    
    echo "Dumping card to file $DUMP_FILE..."
    if [ -z "$KEY" ]; then
        mfoc -O "$DUMP_FILE" &> /tmp/card_dump_output
    else
        mfoc -k "$KEY" -O "$DUMP_FILE" &> /tmp/card_dump_output
    fi
    if [ "$?" != 0 ]; then
        echo "Card dump failed"
        echo "Output logged to /tmp/card_dump_output"
        exit 1
    fi

    echo "Card dumped successfully to $DUMP_FILE"
    rm /tmp/card_dump_output
}

function writetag() {
    echo "Setting UID from dump."
    CARD_UID=$(xxd -l 16 -a -p "$DUMP_FILE")
    nfc-mfsetuid "$CARD_UID" &> /tmp/card_dump_output
    if [ "$?" != "0" ]; then
        echo "Could not write UID."
        echo "Output logged to /tmp/card_dump_output"
        exit 1
    fi
    nfc-mfclassic W ab u "$DUMP_FILE" &> /tmp/card_dump_output
    if [ "$?" != "0" ]; then
        echo "Could not write sectors."
        echo "Output logged to /tmp/card_dump_output"
        exit 1
    fi
}

# Main script
if [ ${#@} -lt 2 ]; then
    help
    exit 1
fi


if [ "$1" = "r" ]; then
    if [ -z "$2" ]; then
        echo "Please provide a key"
        exit 1
    fi
    if [ -z "$3" ]; then
        
        read -p "No dumpfile specified. Dump to $DUMP_FILE? ([y]/n)" -n 1 -r
        if [ ! $REPLY = "y" ]; then
            DUMP_FILE=$2
            echo "Dumping to $DUMP_FILE instead"
        fi
        
    else
        DUMP_FILE="$3"
    fi
    readtag "$2" "$DUMP_FILE"
elif [ "$1" = "w" ]; then
    if [ -z "$2" ]; then    
        echo "Using default dump file $DUMP_FILE"
    else
        DUMP_FILE="$2"
    fi
    writetag
fi

