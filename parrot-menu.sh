#!/bin/bash

# ============================================
# Parrot Tools List Guide Creator & Navigator
# ============================================

DB_FILE="$HOME/parrot-tools--list-commands.txt"
DESKTOP_DIR="/usr/share/applications"

# --- Function: Create Database from .desktop files ---
parrot_tools_list_guide_creator() {
    echo "Creating Parrot Tools database..."

    cat > "$DB_FILE" << 'EOF'
## Main Categories (Primary)

01-info-gathering
02-vulnerability-analysis
03-webapp-analysis
04-exploitation-tools
05-password-attacks
06-wireless-attacks
07-reverseengineer
08-post-exploit
09-sniffing-spoofing
10-maintaining-access
11-forensics
12-reporting
13-01-can-utils
14-ai-tools
cryptography
Development
GTK
Network
privacy
Utility
serv-09-metasploit-service
serv-11-openvas-service

## Subcategories

01-01-dns-analysis
01-02-identify-live-hosts
01-03-ids-ips-identification
01-04-network-scanners
01-07-osint-analysis
01-08-route-analysis
01-10-smb-analysis
01-11-smtp-analysis
01-12-snmp-analysis
01-13-ssl-analysis
02-01-cisco-tools
02-02-fuzzers
02-03-voip-tools
02-07-stress-testing
03-01-cms-identification
03-04-web-crawlers
03-05-web-vulnerability-scanners
03-06-web-application-proxies
04-01-metasploit-framework
04-02-social-engineering
04-03-exploit-search
04-04-payload-generator
04-05-web-exploit
04-06-db-exploit
04-07-ipv6
05-01-online-attacks
05-02-offline-attacks
05-03-local-attacks
05-05-profile
06-01-wireless-tools
06-01-cisco-attacks
06-02-bluetooth-tools
06-03-rfid-nfc-tools
06-04-other-wireless
06-05-radio-tools
07-01-disassemblers
07-02-debuggers
07-03-decompilers
07-04-radare2
07-05-rizin
08-01-priv-esc
08-02-hash-dump
08-03-pth
09-01-network-sniffers
09-02-network-spoofing
10-01-os-backdoors
10-02-tunneling
10-03-web-backdoors
10-04-av-bypass
11-01-android-tools
11-03-digital-forensics
11-04-forensic-analysis-tools
11-05-forensic-carving-tools
11-07-forensic-imaging-tools
11-08-forensic-suites
11-11-pdf-forensics-tools

#List of all tools and commands from .desktop files

EOF

    for file in "${DESKTOP_DIR}"/parrot-*.desktop; do
        if [[ -f "$file" ]]; then
            echo "$file" >> "$DB_FILE"
            grep -m1 '^Exec=' "$file" | cut -d'=' -f2- >> "$DB_FILE"
            grep -m1 '^Categories=' "$file" | cut -d';' -f1 | sed 's/Categories=//' >> "$DB_FILE"
            echo "" >> "$DB_FILE"
        fi
    done

    echo "Database created successfully: $DB_FILE"
}

# --- Ensure database exists on startup ---
if [[ ! -f "$DB_FILE" ]]; then
    parrot_tools_list_guide_creator
fi

# --- Helper: Read main categories into array ---
read_main_categories() {
    main_categories=()
    local in_main=false
    while IFS= read -r line; do
        if [[ "$line" == "## Main Categories (Primary)" ]]; then
            in_main=true; continue
        elif [[ "$line" == "## Subcategories" ]]; then
            break
        fi
        if $in_main && [[ -n "$line" ]] && [[ ! "$line" =~ ^## ]]; then
            main_categories+=("$line")
        fi
    done < "$DB_FILE"
}

# --- Helper: Read subcategories into array (filtered by prefix) ---
read_subcategories() {
    local prefix="$1"
    subcategories=()
    local in_subs=false
    while IFS= read -r line; do
        if [[ "$line" == "## Subcategories" ]]; then
            in_subs=true; continue
        elif [[ "$line" =~ ^#List ]]; then
            break
        fi
        if $in_subs && [[ -n "$line" ]] && [[ ! "$line" =~ ^## ]]; then
            # Only add subcategories that start with the given prefix
            if [[ "$line" == "${prefix}"* ]]; then
                subcategories+=("$line")
            fi
        fi
    done < "$DB_FILE"
}

# --- Helper: Get prefix from main category ---
get_prefix() {
    local category="$1"
    # Extract the leading number (e.g. "02" from "02-vulnerability-analysis")
    if [[ "$category" =~ ^([0-9]+)- ]]; then
        echo "${BASH_REMATCH[1]}-"
    else
        echo ""
    fi
}

# --- Function: Show tools for a given subcategory ---
show_category_tools() {
    local selected_cat="$1"

    echo ""
    echo "=========================================="
    echo "  Tools in Category: $selected_cat"
    echo "=========================================="
    echo ""

    local count=0
    # Parse the tools section (after "#List of all tools" line)
    local in_tools=false
    local current_cat=""
    local lines=()

    while IFS= read -r line; do
        if [[ "$line" == "#List of all tools"* ]]; then
            in_tools=true; continue
        fi

        if ! $in_tools; then continue; fi

        # Each tool entry is: file path, command, category, blank line
        if [[ -n "$line" ]]; then
            lines+=("$line")
        else
            # Blank line = end of one tool entry
            if [[ ${#lines[@]} -ge 3 ]]; then
                current_cat="${lines[2]}"
                if [[ "$current_cat" == "$selected_cat" ]]; then
                    ((count++))
                    echo "Tool $count:"
                    echo "  App:    ${lines[0]}"
                    echo "  Cmd:    ${lines[1]}"
                    echo "  Cat:    ${lines[2]}"
                    echo ""
                fi
            fi
            lines=()
        fi
    done < "$DB_FILE"

    if [[ $count -eq 0 ]]; then
        echo "  No tools found in this category."
        echo ""
    else
        echo "Total tools found: $count"
        echo ""
    fi
}

# --- Function: Subcategory Menu ---
subcategory_menu() {
    local selected_main="$1"
    local prefix
    prefix=$(get_prefix "$selected_main")

    read_subcategories "$prefix"

    while true; do
        clear
        echo "=============================================="
        echo "  SUBCATEGORIES FOR: $selected_main"
        echo "=============================================="
        echo ""

        if [[ ${#subcategories[@]} -eq 0 ]]; then
            echo "  No subcategories found for this category."
            echo "  Showing tools directly:"
            echo ""
            show_category_tools "$selected_main"
        else
            for i in "${!subcategories[@]}"; do
                printf "  [%d] %s\n" $((i+1)) "${subcategories[$i]}"
            done
            echo ""
        fi

        echo "  [b] Back to Main Menu"
        echo "  [q] Quit"
        echo ""
        read -p "Select an option: " sub_choice

        case "$sub_choice" in
            [qQ])
                echo "Exiting Parrot Tools Navigator. Goodbye!"
                exit 0
                ;;
            [bB])
                return
                ;;
            *)
                if [[ "$sub_choice" =~ ^[0-9]+$ ]] && \
                   [[ "$sub_choice" -ge 1 ]] && \
                   [[ "$sub_choice" -le ${#subcategories[@]} ]]; then
                    local chosen_sub="${subcategories[$((sub_choice-1))]}"
                    clear
                    show_category_tools "$chosen_sub"
                    echo "[b] Back to Subcategories"
                    echo "[q] Quit"
                    read -p "Select option: " back_choice
                    case "$back_choice" in
                        [qQ]) echo "Exiting. Goodbye!"; exit 0 ;;
                        *) continue ;;
                    esac
                else
                    echo "Invalid option. Try again."
                    sleep 1
                fi
                ;;
        esac
    done
}

# --- Function: Main Menu ---
main_menu() {
    read_main_categories

    while true; do
        clear
        echo "=============================================="
        echo "     PARROT TOOLS LIST GUIDE NAVIGATOR"
        echo "=============================================="
        echo ""
        echo "MAIN CATEGORIES:"
        echo ""
        for i in "${!main_categories[@]}"; do
            printf "  [%d] %s\n" $((i+1)) "${main_categories[$i]}"
        done
        echo ""
        echo "  [q] Quit"
        echo ""
        read -p "Select a category: " choice

        case "$choice" in
            [qQ])
                echo "Exiting Parrot Tools Navigator. Goodbye!"
                exit 0
                ;;
            *)
                if [[ "$choice" =~ ^[0-9]+$ ]] && \
                   [[ "$choice" -ge 1 ]] && \
                   [[ "$choice" -le ${#main_categories[@]} ]]; then
                    local selected_main="${main_categories[$((choice-1))]}"
                    subcategory_menu "$selected_main"
                else
                    echo "Invalid option. Try again."
                    sleep 1
                fi
                ;;
        esac
    done
}

# --- Entry Point ---
echo "Parrot Tools List Guide Navigator Starting..."
sleep 1
main_menu