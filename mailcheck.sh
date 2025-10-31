#!/bin/bash

# Office 365 and Google Workspace Connectivity Checker
# GUI Interface using Zenity

TITLE="Email Service Checker"
WIDTH=800
HEIGHT=600

# Function to check DNS records
check_dns() {
    local domain=$1
    local result=""
    
    # Check MX records
    result+="=== MX RECORDS ===\n"
    mx_records=$(dig MX "$domain" +short 2>/dev/null | sort -n)
    if [ -n "$mx_records" ]; then
        result+="$mx_records\n"
    else
        result+="No MX records found\n"
    fi
    
    # Check NS records
    result+="\n=== NS RECORDS ===\n"
    ns_records=$(dig NS "$domain" +short 2>/dev/null)
    if [ -n "$ns_records" ]; then
        result+="$ns_records\n"
    else
        result+="No NS records found\n"
    fi
    
    # Check SPF record
    result+="\n=== SPF RECORD ===\n"
    spf_record=$(dig TXT "$domain" +short 2>/dev/null | grep "v=spf1")
    if [ -n "$spf_record" ]; then
        result+="$spf_record\n"
    else
        result+="No SPF record found\n"
    fi
    
    echo -e "$result"
}

# Function to check Office 365 specific records
check_office365() {
    local domain=$1
    local result=""
    
    result+="=== OFFICE 365 SPECIFIC CHECKS ===\n"
    
    # Check for Office 365 MX records
    result+="\nOffice 365 MX Validation:\n"
    if dig MX "$domain" +short 2>/dev/null | grep -q "mail.protection.outlook.com"; then
        result+="✓ MX records point to Office 365\n"
    else
        result+="✗ MX records NOT pointing to Office 365\n"
    fi
    
    # Check Autodiscover
    result+="\nAutodiscover Check:\n"
    autodiscover=$(dig CNAME "autodiscover.$domain" +short 2>/dev/null)
    if [ -n "$autodiscover" ]; then
        result+="Autodiscover CNAME: $autodiscover\n"
    else
        result+="No Autodiscover CNAME found\n"
    fi
    
    # Check MS TXT record for verification
    result+="\nMicrosoft Verification:\n"
    ms_txt=$(dig TXT "$domain" +short 2>/dev/null | grep "MS=")
    if [ -n "$ms_txt" ]; then
        result+="Microsoft TXT record found\n"
    else
        result+="No Microsoft verification TXT record\n"
    fi
    
    echo -e "$result"
}

# Function to check Google Workspace specific records
check_google_workspace() {
    local domain=$1
    local result=""
    
    result+="=== GOOGLE WORKSPACE SPECIFIC CHECKS ===\n"
    
    # Check for Google MX records
    result+="\nGoogle Workspace MX Validation:\n"
    if dig MX "$domain" +short 2>/dev/null | grep -q "aspmx.l.google.com"; then
        result+="✓ MX records point to Google Workspace\n"
    else
        result+="✗ MX records NOT pointing to Google Workspace\n"
    fi
    
    # Check Google Site Verification
    result+="\nGoogle Verification:\n"
    google_txt=$(dig TXT "$domain" +short 2>/dev/null | grep "google-site-verification")
    if [ -n "$google_txt" ]; then
        result+="Google verification TXT record found\n"
    else
        result+="No Google verification TXT record\n"
    fi
    
    echo -e "$result"
}

# Function to perform connectivity tests
check_connectivity() {
    local domain=$1
    local result=""
    
    result+="=== CONNECTIVITY TESTS ===\n"
    
    # Test basic connectivity
    result+="\nBasic Connectivity:\n"
    if ping -c 2 "$domain" &>/dev/null; then
        result+="✓ Domain is reachable\n"
    else
        result+="✗ Domain is not reachable\n"
    fi
    
    # Test DNS resolution
    result+="\nDNS Resolution:\n"
    if nslookup "$domain" &>/dev/null; then
        result+="✓ DNS resolution working\n"
    else
        result+="✗ DNS resolution failed\n"
    fi
    
    echo -e "$result"
}

# Main function
main() {
    while true; do
        # Main menu
        choice=$(zenity --list \
            --title="$TITLE" \
            --width=$WIDTH \
            --height=$HEIGHT \
            --text="Select an option:" \
            --column="Option" \
            "Check Office 365 Configuration" \
            "Check Google Workspace Configuration" \
            "Check Custom Domain" \
            "Exit" \
            2>/dev/null)
        
        if [ $? -ne 0 ] || [ "$choice" = "Exit" ]; then
            zenity --info --title="$TITLE" --text="Thank you for using Email Service Checker!" --width=300
            exit 0
        fi
        
        # Get domain from user
        domain=$(zenity --entry \
            --title="$TITLE" \
            --text="Enter the domain to check (without www):" \
            --entry-text="example.com" \
            --width=400 \
            2>/dev/null)
        
        if [ $? -ne 0 ] || [ -z "$domain" ]; then
            zenity --error --text="No domain entered!" --width=300
            continue
        fi
        
        # Remove any protocol prefixes
        domain=$(echo "$domain" | sed 's|^https://||;s|^http://||;s|^www\.||')
        
        # Show progress
        (
            echo "10" ; sleep 1
            echo "# Checking basic connectivity..." ; sleep 1
            echo "30" ; sleep 1
            echo "# Checking DNS records..." ; sleep 1
            echo "50" ; sleep 1
            echo "# Checking service-specific configuration..." ; sleep 1
            echo "80" ; sleep 1
            echo "# Generating report..." ; sleep 1
            echo "100" ; sleep 1
        ) | zenity --progress \
            --title="Checking Domain" \
            --text="Initializing checks..." \
            --percentage=0 \
            --auto-close \
            --width=300
        
        if [ $? -ne 0 ]; then
            continue
        fi
        
        # Perform checks based on selection
        case "$choice" in
            "Check Office 365 Configuration")
                report=$(check_connectivity "$domain")
                report+="\n$(check_dns "$domain")"
                report+="\n$(check_office365 "$domain")"
                ;;
            "Check Google Workspace Configuration")
                report=$(check_connectivity "$domain")
                report+="\n$(check_dns "$domain")"
                report+="\n$(check_google_workspace "$domain")"
                ;;
            "Check Custom Domain")
                report=$(check_connectivity "$domain")
                report+="\n$(check_dns "$domain")"
                report+="\n$(check_office365 "$domain")"
                report+="\n$(check_google_workspace "$domain")"
                ;;
            *)
                continue
                ;;
        esac
        
        # Display results
        zenity --text-info \
            --title="Results for $domain" \
            --width=900 \
            --height=700 \
            --filename=<(echo -e "$report") \
            --checkbox="Save report to file" \
            2>/dev/null
        
        if [ $? -eq 0 ] && [ $? -ne 1 ]; then
            # Save to file if checkbox was checked
            filename=$(zenity --file-selection --save --confirm-overwrite --title="Save Report As" --filename="$domain-report.txt")
            if [ -n "$filename" ]; then
                echo -e "$report" > "$filename"
                zenity --info --text="Report saved to: $filename" --width=400
            fi
        fi
    done
}

# Check if required tools are installed
check_dependencies() {
    local missing=()
    
    for cmd in zenity dig ping nslookup; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        zenity --error \
            --text="The following required tools are missing:\n${missing[*]}\n\nPlease install them and try again." \
            --width=400
        exit 1
    fi
}

# Initialize
check_dependencies
main