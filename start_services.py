#!/usr/bin/env python3
"""
AtithiVerse Service Starter
This script helps you start both the main website and AI service
"""

import subprocess
import sys
import time
import os
from threading import Thread

def start_ai_service():
    """Start the AI service (travel_bot.py) on port 5001"""
    print("🤖 Starting AI Service on port 5001...")
    try:
        # travel_bot.py is in the root directory
        subprocess.run([sys.executable, 'travel_bot.py'], check=True)
    except subprocess.CalledProcessError as e:
        print(f"❌ AI Service failed to start: {e}")
    except KeyboardInterrupt:
        print("🛑 AI Service stopped")

def start_main_website():
    """Start the main website (app.py) on port 5000"""
    print("🌐 Starting Main Website on port 5000...")
    try:
        # app.py is in the Website directory
        subprocess.run([sys.executable, 'Website/app.py'], check=True)
    except subprocess.CalledProcessError as e:
        print(f"❌ Main Website failed to start: {e}")
    except KeyboardInterrupt:
        print("🛑 Main Website stopped")

def main():
    print("🚀 Starting AtithiVerse Services...")
    print("=" * 50)
    
    # Start AI service in a separate thread
    ai_thread = Thread(target=start_ai_service, daemon=True)
    ai_thread.start()
    
    # Give AI service time to start
    time.sleep(3)
    
    # Start main website (this will block)
    try:
        start_main_website()
    except KeyboardInterrupt:
        print("\n🛑 Shutting down services...")
        print("✅ Services stopped successfully!")

if __name__ == "__main__":
    main()
