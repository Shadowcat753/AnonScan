#!/bin/bash

# Color Definitions
RED='\e[31m'
GREEN='\e[32m'
GREY='\e[90m'        # Dark/Bright Black Grey
LIGHT_GREY='\e[37m'  # Standard Light Grey
RESET='\e[0m'
PURPLE='\e[35m'

#emoji time!
SUCCESS="${GREEN}[✔]${RESET}"
ERROR="${RED}[✖]${RESET}"
ALERT="${YELLOW}[⚠️]${RESET}"
INFO="${CYAN}[ℹ️]${RESET}"


###Script Start!
target="8.8.8.8"
###start internet check
echo "[*] Checking Internet Connection... [*]"
ping -c 1 $target > /dev/null
if [ $? -eq 0 ]; then
	echo -e "${GREEN}[*] You have internet connection... Moving on to anonimity check... [*]${RESET}"
else
	echo -e "${RED}No connection established.${RESET}"
	exit 1
fi
###end internet check
echo "..." #dead space between lines...
###check for proxychains installation
which proxychains > /dev/null
if [ $? -eq 0 ]; then
	echo "Proxychains installed. Moving on to verifying TOR."
else
	echo "Installing proxychains"
	apt install proxychains
fi
###end proxychains
echo "..." #dead space between lines...
###check for tor proxychains

real_ip=$(curl -s ifconfig.me)
obscured=$(proxychains -q curl -s https://icanhazip.com)

echo "Your real IP is: $real_ip"
echo "Your secure IP is: $obscured"

if [ -z "$obscured" ] || [ "$real_ip" == "$obscured" ]; then
	echo -e "[$ALERT] ${RED}[*]Alert![*]${RESET} - Proxychains/Tor failed! You are not anonymous!"
	exit 1
else
	echo -e "[$SUCCESS] ${GREEN}Success:${LIGHT_GREY}[...]${GREY}Shadows entered${LIGHT_GREY}[...]${RESET}"
fi

###all is well!
echo "..." ###blank line
#############################################
### ----- part 2: Target Scanning! ------ ###
#############################################

choice=""

echo -e
cat << "EOF"
 ░▒▓██████▓▒░░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░ ░▒▓███████▓▒░░▒▓██████▓▒░ ░▒▓██████▓▒░░▒▓███████▓▒░  
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓████████▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░      ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ 
                                                                                                          
                                                                                                          
EOF
echo -e "                                                 ${PURPLE} ===[ AnonScan v1.0 | Created by Shadowcat ]===${RESET}\n"
while [ "$choice" != "1" ] && [ "$choice" != "2" ]; do
	echo ""
	echo ""
	echo ""
	echo ""
	echo "Time to start a scan 😈"
	echo ""
	echo "Choose your target type:"
	echo ""
	echo "[1] Scan a single target."
	echo "[2] Scan a list of targets from a file."
	read -p "What will it be?: " choice

	if [ "$choice" != "1" ] && [ "$choice" != "2" ]; then
		echo "Invalid choice. please select 1 or 2."
	fi
done


# Choice 1: Single Target
if [ "$choice" == "1" ]; then
        read -p "Enter target IP or domain: " TARGET
        echo -e "${GREEN}Target Acquired: $TARGET, starting scan...${RESET}"
        
        proxychains -q nmap -sCV -Pn --host-timeout 3m --max-retries 1 "$TARGET" > "scan_results_${TARGET}.txt"

        if [ $? -eq 0 ]; then
                echo -e "${GREEN}Scan complete! Results saved to scan_results_${TARGET}.txt${RESET}"
        else
                echo -e "$ALERT ${RED}Scan failed or timed out.${RESET}"
        fi

# Choice 2: List of Targets from File
else
        read -p "Enter path to target file (eg: /home/file/targets.txt): " TARGET_FILE
        
        if [ ! -f "$TARGET_FILE" ]; then
                echo -e "${RED}Error: File $TARGET_FILE not found!${RESET}"
                exit 1
        fi

        for TARGET in $(cat "$TARGET_FILE"); do
                echo "-------------------------"
                echo -e "${GREEN}Target Acquired: $TARGET, starting scan...${RESET}"
                
                proxychains -q nmap -sCV -Pn --host-timeout 3m --max-retries 1 "$TARGET" > "scan_results_${TARGET}.txt"

                if [ $? -ne 0 ]; then
                        echo -e "${RED}Scan failed or timed out on $TARGET${RESET}, skipping..."
                        continue
                fi

                echo -e "${GREEN}Scan complete for $TARGET, results saved!${RESET}"
        done
fi

