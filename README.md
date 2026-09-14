# AnonScan v1.1 😈

**AnonScan** is an automated Nmap scanning tool designed for Kali Linux that routes target reconnaissance over the Tor network using Proxychains.

Created by **Shadowcat**.

## Features
- 🕵️ **Anonymity Verification:** Compares local vs. proxy IP addresses before scanning.
- 🎯 **Flexible Input:** Supports both single target scanning and target list files.
- 🛡️ **Hanging Prevention:** Built-in timeout flags (`--host-timeout`, `--max-retries`) to drop dead proxy connections smoothly.
- 🎨 **Custom Terminal UI:** Colorful ANSI output, custom ASCII banners, and emojis.

## Usage
```bash
chmod +x anonscan.sh
./anonscan.sh

