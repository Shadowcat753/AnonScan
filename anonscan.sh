#!/bin/bash

# Color Definitions
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
GREY='\e[90m'
LIGHT_GREY='\e[37m'
PURPLE='\e[35m'
RESET='\e[0m'

# UI Badges
SUCCESS="${GREEN}[✔]${RESET}"
ERROR="${RED}[✖]${RESET}"
ALERT="${YELLOW}[⚠️]${RESET}"
INFO="${CYAN}[ℹ️]${RESET}"


# Loading Spinner Function
spin() {
    local pid=$1
    local target=$2
    local delay=0.15
    # Standard ASCII spinner frames
    local spinstr='|/-\'
    
    tput civis 2>/dev/null
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r\033[K ${PURPLE}[%c]${RESET} Scanning %s over Tor..." "$spinstr" "$target"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    
    printf "\r\033[K"
    tput cnorm 2>/dev/null
}

clear

# Check Internet Connection
echo -e "$INFO Checking Internet Connection..."
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo -e "$SUCCESS Internet connected. Proceeding to anonymity verification..."
else
    echo -e "$ERROR ${RED}No internet connection established. Exiting.${RESET}"
    exit 1
fi

echo "..."

# Check Proxychains Installation
if which proxychains > /dev/null 2>&1; then
    echo -e "$SUCCESS Proxychains installed. Verifying Tor circuit..."
else
    echo -e "$INFO Proxychains not found. Installing..."
    sudo apt update && sudo apt install -y proxychains
fi

echo "..."

# Verify Anonymity
real_ip=$(curl -s --max-time 5 ifconfig.me)
obscured=$(proxychains -q curl -s --max-time 10 https://icanhazip.com | tr -d '\r\n')

echo -e "${GREY}[*] Direct IP  : $real_ip${RESET}"
echo -e "${GREY}[*] Tor Circuit: $obscured${RESET}"

if [ -z "$obscured" ] || [ "$real_ip" == "$obscured" ]; then
    echo -e "$ALERT ${RED}Anonymity Check Failed! You are not routing through Tor.${RESET}"
    exit 1
else
    echo -e "$SUCCESS ${GREEN}Success:${RESET} ${GREY}Shadows entered. Tor route active.${RESET}\n"
fi

# Banner Output
echo -e "${PURPLE}"
cat << "EOF"
 ░▒▓██████▓▒░░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░ ░▒▓███████▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
EOF
echo -e "                                                 ${PURPLE}===[ AnonScan v1.0 | Shadowcat ]===${RESET}\n"

choice=""
while [ "$choice" != "1" ] && [ "$choice" != "2" ]; do
    echo -e "${PURPLE}😈 Time to start a scan${RESET}\n"
    echo "Choose your target type:"
    echo " [1] Scan a single target"
    echo " [2] Scan a list of targets from a file"
    echo ""
    read -p "What will it be? [1/2]: " choice

    if [ "$choice" != "1" ] && [ "$choice" != "2" ]; then
        echo -e "$ALERT ${RED}Invalid choice. Please select 1 or 2.${RESET}\n"
    fi
done

# Choice 1: Single Target
if [ "$choice" == "1" ]; then
    read -p "Enter target IP or domain: " TARGET
    TARGET_CLEAN=$(echo "$TARGET" | sed -e 's|^[^:]*://||' -e 's|/|_|g')
    
    echo -e "$INFO ${GREEN}Target Acquired:${RESET} $TARGET"
    
	# Launch background scan (silent output)
	proxychains -q nmap -sCV -Pn -n --data-length 16 --host-timeout 3m --max-retries 1 "$TARGET" > "scan_results_${TARGET_CLEAN}.txt" 2>&1 &
	NMAP_PID=$!
	
	# Trigger spinner
	spin $NMAP_PID "$TARGET"
	
	# Wait for completion
	wait $NMAP_PID
	SCAN_RESULT=$?
	
    if [ $? -eq 0 ]; then
        echo -e "$SUCCESS ${GREEN}Scan complete! Saved to scan_results_${TARGET_CLEAN}.txt${RESET}"
    else
        echo -e "$ERROR ${RED}Scan failed or timed out on $TARGET.${RESET}"
    fi

# Choice 2: File Target Processing
else
    read -p "Enter path to target file: " TARGET_FILE
    
    if [ ! -f "$TARGET_FILE" ]; then
        echo -e "$ERROR ${RED}File $TARGET_FILE not found! Exiting.${RESET}"
        exit 1
    fi

    echo -e "$INFO Processing targets from $TARGET_FILE...\n"

    while IFS= read -r TARGET || [ -n "$TARGET" ]; do
        # Ignore empty lines and comments
        [[ -z "$TARGET" || "$TARGET" =~ ^# ]] && continue
        TARGET=$(echo "$TARGET" | tr -d '\r')
        TARGET_CLEAN=$(echo "$TARGET" | sed -e 's|^[^:]*://||' -e 's|/|_|g')

        echo -e "--------------------------------------------------"
        echo -e "$INFO ${GREEN}Target Acquired:${RESET} $TARGET"

	# Launch background scan (silent output)
	proxychains -q nmap -sCV -Pn -n --data-length 16 --host-timeout 3m --max-retries 1 "$TARGET" > "scan_results_${TARGET_CLEAN}.txt" 2>&1 &
	NMAP_PID=$!
	
	# Trigger spinner
	spin $NMAP_PID "$TARGET"
	
	# Wait for completion
	wait $NMAP_PID
	SCAN_RESULT=$?

        if [ $? -ne 0 ]; then
            echo -e "$ERROR ${RED}Scan failed or timed out on $TARGET. Skipping...${RESET}"
            continue
        fi

        echo -e "$SUCCESS ${GREEN}Scan complete! Saved to scan_results_${TARGET_CLEAN}.txt${RESET}"
    done < "$TARGET_FILE"
fi


