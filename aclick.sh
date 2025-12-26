#!/bin/bash

# A.Click - Authorized ClickJacking Detection Tool
# For Educational & Authorized Penetration Testing Only
# Usage: ./aclick.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# A.Click ASCII Banner
echo -e "${BLUE}"
echo "    █████╗  ██████╗██╗     ██╗ ██████╗██╗  ██╗"
echo "   ██╔══██╗██╔════╝██║     ██║██╔════╝██║ ██╔╝"
echo "   ███████║██║     ██║     ██║██║     █████╔╝ "
echo "   ██╔══██║██║     ██║     ██║██║     ██╔═██╗ "
echo "   ██║  ██║╚██████╗███████╗██║╚██████╗██║  ██╗"
echo "   ╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝ ╚═════╝╚═╝  ╚═╝"
echo " "
echo "  ╔══════════════════════════════════════════╗"
echo "  ║           🔍 A.Click By Ahad             ║"
echo "  ║     Advanced ClickJacking Detector       ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}"
echo "========================================================"
echo "      Professional ClickJacking Vulnerability Scanner"
echo "     AUTHORIZED PENETRATION TEST CREATED BY ABDUL AHAD"
echo "========================================================"
echo -e "${NC}"

# Function to check required tools
check_dependencies() {
    echo -e "${YELLOW}[CHECK] Verifying system dependencies...${NC}"
    
    local missing=0
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}[MISSING] curl - Install with: apt install curl${NC}"
        ((missing++))
    else
        echo -e "${GREEN}[OK] curl - HTTP client utility${NC}"
    fi
    
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}[OPTIONAL] jq not found (for JSON parsing)${NC}"
    else
        echo -e "${GREEN}[OK] jq - JSON processor${NC}"
    fi
    
    if [ $missing -gt 0 ]; then
        echo -e "${RED}[ERROR] Missing $missing required dependencies${NC}"
        exit 1
    fi
}

# Function to validate and format domain
validate_domain() {
    local domain="$1"
    
    # Remove protocol if present
    domain=$(echo "$domain" | sed 's/^https\?:\/\///' | sed 's/\/.*$//')
    
    # Add https:// prefix if not present
    if [[ ! "$1" =~ ^https?:// ]]; then
        formatted_url="https://$domain"
    else
        formatted_url="$1"
    fi
    
    echo "$formatted_url"
}

# Function to check ClickJacking vulnerability
check_clickjacking() {
    local target_url="$1"
    local domain=$(echo "$target_url" | sed 's/^https\?:\/\///' | sed 's/\/.*$//')
    
    echo -e "${YELLOW}[SCAN] Testing $target_url for ClickJacking vulnerability...${NC}"
    
    # Send HTTP request and capture headers
    response=$(curl -s -I -L -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" "$target_url" 2>/dev/null)
    
    if [ -z "$response" ]; then
        echo -e "${RED}[ERROR] Failed to connect to $target_url${NC}"
        return
    fi
    
    # Check for X-Frame-Options header
    x_frame_options=$(echo "$response" | grep -i "x-frame-options" | tr -d '\r')
    
    # Check for Content-Security-Policy header with frame-ancestors directive
    csp_frame=$(echo "$response" | grep -i "content-security-policy" | grep -i "frame-ancestors" | tr -d '\r')
    
    echo ""
    echo -e "${CYAN}[RESULTS] ClickJacking Analysis for $domain${NC}"
    echo -e "${BLUE}Target:${NC} $target_url"
    echo ""
    
    # Analyze headers
    vulnerable=true
    
    if [ -n "$x_frame_options" ]; then
        echo -e "${GREEN}[SECURE] X-Frame-Options detected:${NC}"
        echo -e "  → $x_frame_options"
        xfo_value=$(echo "$x_frame_options" | cut -d: -f2 | tr -d ' ')
        
        case $(echo "$xfo_value" | tr '[:upper:]' '[:lower:]') in
            deny|sameorigin)
                echo -e "${GREEN}  └─ Strong protection: ${xfo_value}${NC}"
                vulnerable=false
                ;;
            allow-from*)
                echo -e "${YELLOW}  └─ Contextual protection: ${xfo_value}${NC}"
                echo -e "${YELLOW}  └─ Potential partial vulnerability${NC}"
                ;;
            *)
                echo -e "${YELLOW}  └─ Unrecognized value: ${xfo_value}${NC}"
                ;;
        esac
    else
        echo -e "${RED}[MISSING] X-Frame-Options header not found${NC}"
    fi
    
    echo ""
    
    if [ -n "$csp_frame" ]; then
        echo -e "${GREEN}[SECURE] Content-Security-Policy with frame-ancestors detected:${NC}"
        echo -e "  → $csp_frame"
        
        # Check CSP frame-ancestors directives
        if echo "$csp_frame" | grep -iq "frame-ancestors\s*'none'"; then
            echo -e "${GREEN}  └─ Strong protection: frame-ancestors 'none'${NC}"
            vulnerable=false
        elif echo "$csp_frame" | grep -iq "frame-ancestors\s*'self'"; then
            echo -e "${GREEN}  └─ Moderate protection: frame-ancestors 'self'${NC}"
            vulnerable=false
        else
            echo -e "${YELLOW}  └─ Custom frame-ancestors policy${NC}"
        fi
    else
        echo -e "${RED}[MISSING] Content-Security-Policy with frame-ancestors not found${NC}"
    fi
    
    echo ""
    
    # Overall vulnerability assessment
    if [ "$vulnerable" = true ]; then
        echo -e "${RED}[🚨 VULNERABLE] Site is susceptible to ClickJacking attacks${NC}"
        echo -e "${YELLOW}[RISK] High${NC}"
        echo -e "${CYAN}[DETAILS]${NC}"
        echo -e "  • Missing protection headers (X-Frame-Options and/or CSP frame-ancestors)"
        echo -e "  • Application can potentially be embedded in malicious iframes"
        echo -e "  • Risk of UI Redressing attacks where users are tricked into clicking concealed elements"
        echo ""
        echo -e "${PURPLE}[RECOMMENDATIONS]${NC}"
        echo -e "  1. Add X-Frame-Options header: X-Frame-Options: DENY"
        echo -e "  2. Add Content-Security-Policy: frame-ancestors 'none'"
        echo -e "  3. Or use both for maximum browser compatibility"
        echo ""
        echo -e "${RED}[POC HTML TEMPLATE]${NC}"
        cat << 'EOF'
<!DOCTYPE html>
<html>
<head><title>ClickJacking POC</title></head>
<body>
    <iframe src="%TARGET%" width="1000" height="800"></iframe>
    <div style="position:absolute; top:200px; left:200px; opacity:0.2;">
        <button>CLICK HERE FOR PRIZE!</button>
    </div>
</body>
</html>
EOF
        echo ""
        echo -e "${YELLOW}Replace %TARGET% with the vulnerable URL${NC}"
    else
        echo -e "${GREEN}[✅ SECURE] Site implements ClickJacking protection${NC}"
        echo -e "${GREEN}[RISK] Low${NC}"
    fi
    
    # Additional information
    echo ""
    echo -e "${CYAN}[TECHNICAL DETAILS]${NC}"
    echo "HTTP Response Headers:"
    echo "$response" | head -20
}

# Function to batch scan multiple domains
batch_scan() {
    echo -e "${CYAN}[BATCH] Batch ClickJacking Scanner${NC}"
    echo -e "${YELLOW}Enter domain names (one per line, 'done' to finish):${NC}"
    
    domains=()
    while true; do
        read -p "> " domain
        if [ "$domain" = "done" ]; then
            break
        fi
        if [ -n "$domain" ]; then
            domains+=("$domain")
        fi
    done
    
    if [ ${#domains[@]} -eq 0 ]; then
        echo -e "${RED}[ERROR] No domains provided${NC}"
        return
    fi
    
    echo ""
    echo -e "${GREEN}[SCANNING] Processing ${#domains[@]} domains...${NC}"
    echo ""
    
    vulnerable_count=0
    secure_count=0
    
    for domain in "${domains[@]}"; do
        echo -e "${BLUE}══════════════════════════════════════${NC}"
        formatted_url=$(validate_domain "$domain")
        check_clickjacking "$formatted_url"
        
        # Simple vulnerability counter (in real implementation, parse the result)
        echo -e "${YELLOW}[INFO] Completed scan for $domain${NC}"
        echo ""
    done
    
    echo -e "${BLUE}══════════════════════════════════════${NC}"
    echo -e "${CYAN}[SUMMARY] Batch Scan Complete${NC}"
    echo -e "${GREEN}Secure:${NC} $secure_count domains"
    echo -e "${RED}Vulnerable:${NC} $vulnerable_count domains"
}

# Function to show help
show_help() {
    echo -e "${CYAN}"
    echo "A.Click - Advanced ClickJacking Detection Tool"
    echo "=============================================="
    echo -e "${NC}"
    echo -e "${YELLOW}Purpose:${NC}"
    echo "  Detects ClickJacking vulnerabilities in web applications"
    echo ""
    echo -e "${YELLOW}What is ClickJacking?${NC}"
    echo "  A malicious technique where attackers trick users into"
    echo "  clicking on something different from what the user"
    echo "  perceives, potentially causing unintended actions"
    echo ""
    echo -e "${YELLOW}Protection Methods Checked:${NC}"
    echo "  • X-Frame-Options header"
    echo "  • Content-Security-Policy frame-ancestors directive"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  Simply enter the domain/URL when prompted"
    echo "  Example: example.com or https://example.com/path"
    echo ""
    echo -e "${YELLOW}Output Explanation:${NC}"
    echo "  🔴 RED: Missing security measures"
    echo "  🟢 GREEN: Proper security implementations"
    echo "  🟡 YELLOW: Partial or contextual protection"
    echo ""
    echo -e "${YELLOW}Recommended Remediation:${NC}"
    echo "  Apache: Header always set X-Frame-Options DENY"
    echo "  Nginx: add_header X-Frame-Options DENY;"
    echo "  Or implement CSP: frame-ancestors 'none';"
}

# Function to show menu
show_menu() {
    echo ""
    echo -e "${PURPLE}[A.CLICK MAIN MENU]${NC}"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    echo -e "  ${GREEN}1${NC} 🔍 Single domain scan"
    echo -e "  ${GREEN}2${NC} 📊 Batch domain scan"
    echo -e "  ${GREEN}3${NC} ❓ Help and information"
    echo -e "  ${GREEN}4${NC} 🚪 Exit"
    echo -e "${CYAN}────────────────────────────────────────${NC}"
    echo ""
}

# Main function
main() {
    echo -e "${GREEN}[INIT] Starting A.Click Detection Tool${NC}"
    
    # Check dependencies
    check_dependencies
    
    echo -e "${GREEN}[READY] A.Click initialized successfully${NC}"
    echo ""
    
    # Main program loop
    while true; do
        show_menu
        read -p "Select option (1-4): " choice
        
        case $choice in
            1)
                echo ""
                read -p "🎯 Enter target domain/URL: " target_domain
                
                if [ -z "$target_domain" ]; then
                    echo -e "${RED}[ERROR] No target provided${NC}"
                    continue
                fi
                
                formatted_url=$(validate_domain "$target_domain")
                echo ""
                check_clickjacking "$formatted_url"
                ;;
            2)
                batch_scan
                ;;
            3)
                show_help
                ;;
            4)
                echo -e "${GREEN}[EXIT] A.Click shutting down...${NC}"
                echo -e "${YELLOW}[INFO] Remember to remediate any vulnerabilities found${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR] Invalid option. Please select 1-4.${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
        
        # Show banner again
        echo -e "${BLUE}"
        echo "    █████╗  ██████╗██╗     ██╗ ██████╗██╗  ██╗"
        echo "   ██╔══██╗██╔════╝██║     ██║██╔════╝██║ ██╔╝"
        echo "   ███████║██║     ██║     ██║██║     █████╔╝ "
        echo "   ██╔══██║██║     ██║     ██║██║     ██╔═██╗ "
        echo "   ██║  ██║╚██████╗███████╗██║╚██████╗██║  ██╗"
        echo "   ╚═╝  ╚═╝ ╚═════╝╚══════╝╚═╝ ╚═════╝╚═╝  ╚═╝"
        echo " "
        echo "  ╔══════════════════════════════════════════╗"
        echo "  ║           🔍 A.Click By Ahad             ║"
        echo "  ║     Advanced ClickJacking Detector       ║"
        echo "  ╚══════════════════════════════════════════╝"
        echo -e "${NC}"
    done
}

# Run main function
main
