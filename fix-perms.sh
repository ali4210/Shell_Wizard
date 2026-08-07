#!/usr/bin/env bash
# ====================================================================
# 🧙♂️ SHELL-WIZARD - AUTOMATIC POSIX PERMISSION SANITIZER
# ====================================================================

echo "--> Scanning and applying +x executable permissions to all shell scripts..."

# Recursively find all .sh files in root and subdirectories and make them executable
find . -type f -name "*.sh" -exec chmod +x {} +

echo "[✔] All shell scripts in Shell_Wizard are now executable!"
