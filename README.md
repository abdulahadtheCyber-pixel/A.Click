## ⚠️ Disclaimer
This tool is intended for Educational & Authorized Penetration Testing Only. The author is not responsible for any misuse or damage caused by this program. Always ensure you have explicit, written permission from the asset owner before scanning.

# A.Click
A.Click: An advanced Bash-based ClickJacking vulnerability scanner for security professionals. Features automated header analysis (XFO &amp; CSP), batch scanning, and PoC template generation.

# A.Click - Advanced ClickJacking Detector
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey)

**A.Click** is a professional-grade Bash tool designed for authorized penetration testers and security researchers to identify ClickJacking (UI Redressing) vulnerabilities in web applications. It analyzes HTTP response headers for missing or misconfigured security directives.
![A.Click Screenshot](screenshot.PNG)
## 🚀 Features
- **Header Analysis**: Deep inspection of `X-Frame-Options` (XFO) and `Content-Security-Policy` (CSP) `frame-ancestors`.
- **Batch Scanning**: Capability to scan multiple domains in a single session.
- **PoC Generator**: Automatically provides an HTML template for Proof of Concept (PoC) if a site is found vulnerable.
- **Visual Reports**: Color-coded terminal output for high-speed vulnerability triaging.
- **Zero Configuration**: Lightweight script with minimal dependencies.

## 📋 Prerequisites

The tool requires the following utilities:
- `curl`: For performing HTTP requests.
- `jq` (Optional): For enhanced result processing.

Install dependencies on Debian/Ubuntu/Kali Linux:
```bash
sudo apt update && sudo apt install curl jq -y
git clone https://github.com/YourUsername/AClick.git
cd AClick
chmod +x aclick.sh
./aclick.sh
