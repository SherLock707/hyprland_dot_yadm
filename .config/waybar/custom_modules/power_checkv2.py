#!/usr/bin/env python3
"""
Power Outage Monitor - Monitors network connectivity and suspends system during power outages.
"""

import subprocess
import os
import time
import sys
from pathlib import Path

# Configuration
KILLSWITCH_FILE = Path("/tmp/POWER_OUTAGE_KILLSWITCH")
HOST_TO_PING = "192.168.0.88"
ROUTER_TO_PING = "192.168.0.1"
PING_TIMEOUT = 1.0
INITIAL_FAILED_COUNT = 5
SUSPEND_COUNTDOWN = 3
LOOP_DELAY = 0.1
NOTIFICATION_ICON = "/home/itachi/.config/dunst/images/bell.png"

# Global debug flag
DEBUG = False


def debug_print(message: str) -> None:
    """Print debug message if debug mode is enabled."""
    if DEBUG:
        print(f"[DEBUG] {message}")


def ping_host(host: str, timeout: float = PING_TIMEOUT) -> bool:
    """
    Ping a host and return True if successful, False otherwise.
    
    Args:
        host: IP address or hostname to ping
        timeout: Timeout in seconds for ping command
        
    Returns:
        bool: True if ping successful, False otherwise
    """
    ping_cmd = ["ping", "-W", str(timeout), "-c", "1", host]
    debug_print(f"Pinging {host} with timeout {timeout}s")
    try:
        result = subprocess.run(
            ping_cmd, 
            capture_output=True, 
            text=True, 
            timeout=timeout + 1
        )
        success = result.returncode == 0
        debug_print(f"Ping to {host}: {'SUCCESS' if success else 'FAILED'}")
        return success
    except (subprocess.TimeoutExpired, subprocess.CalledProcessError, FileNotFoundError) as e:
        debug_print(f"Ping to {host} failed with exception: {e}")
        return False


def send_notification(title: str, message: str, urgency: str = "low", timeout: int = 0) -> None:
    """
    Send desktop notification using notify-send.
    
    Args:
        title: Notification title
        message: Notification message
        urgency: Notification urgency level (low, normal, critical)
        timeout: Timeout in milliseconds (0 for default)
    """
    cmd = [
        "notify-send",
        "-e",
        "-a", title,
        "-h", "string:x-canonical-private-synchronous:power_notif",
        "-u", urgency,
        "-i", NOTIFICATION_ICON
    ]
    
    if timeout > 0:
        cmd.extend(["-t", str(timeout)])
    
    cmd.append(message)
    
    debug_print(f"Sending notification: {title} - {message}")
    try:
        subprocess.run(cmd, check=False, capture_output=True)
    except FileNotFoundError:
        debug_print("notify-send not available")
        pass  # notify-send not available


def check_killswitch_exists() -> bool:
    """Check if the killswitch file exists."""
    exists = KILLSWITCH_FILE.exists()
    debug_print(f"Killswitch file check: {'EXISTS' if exists else 'NOT FOUND'}")
    return exists


def suspend_system() -> None:
    """Suspend the system."""
    debug_print("Attempting to suspend system...")
    try:
        subprocess.run(["systemctl", "suspend"], check=True)
        debug_print("System suspend command executed")
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        debug_print(f"Failed to suspend system: {e}")
        pass  # Failed to suspend


def main():
    """Main monitoring loop."""
    global DEBUG
    
    # Check for debug flag
    if len(sys.argv) > 1 and sys.argv[1] == "-d":
        DEBUG = True
        debug_print("Debug mode enabled")
    
    failed_count = INITIAL_FAILED_COUNT
    countdown_active = False
    countdown_remaining = SUSPEND_COUNTDOWN
    
    debug_print(f"Starting power outage monitor")
    debug_print(f"Host to monitor: {HOST_TO_PING}")
    debug_print(f"Router fallback: {ROUTER_TO_PING}")
    debug_print(f"Killswitch file: {KILLSWITCH_FILE}")
    debug_print(f"Initial failed count: {INITIAL_FAILED_COUNT}")
    debug_print(f"Suspend countdown: {SUSPEND_COUNTDOWN}")
    
    while True:
        try:
            # Check if killswitch file exists
            if not check_killswitch_exists():
                # Reset state when killswitch is removed
                if countdown_active:
                    debug_print("Killswitch removed, aborting countdown")
                    send_notification("Power failure", "Suspend aborted - killswitch removed")
                    countdown_active = False
                    failed_count = INITIAL_FAILED_COUNT
                    countdown_remaining = SUSPEND_COUNTDOWN
                
                time.sleep(LOOP_DELAY)
                continue
            
            # If countdown is active, check if killswitch still exists
            if countdown_active:
                debug_print(f"Countdown active, remaining: {countdown_remaining}")
                if not check_killswitch_exists():
                    debug_print("Killswitch removed during countdown, aborting")
                    send_notification("Power failure", "Suspend aborted - killswitch removed")
                    countdown_active = False
                    failed_count = INITIAL_FAILED_COUNT
                    countdown_remaining = SUSPEND_COUNTDOWN
                    continue
                
                # Continue with countdown
                countdown_remaining -= 1
                if countdown_remaining > 0:
                    debug_print(f"Countdown: {countdown_remaining} seconds remaining")
                    send_notification("Power failure", f"Suspending in {countdown_remaining}")
                    time.sleep(1)  # 1-second countdown intervals
                    continue
                else:
                    # Countdown finished, suspend the system
                    debug_print("Countdown finished, suspending system")
                    send_notification("Power failure", "Suspending now", timeout=3000)
                    time.sleep(1)  # Brief delay to show notification
                    suspend_system()
                    
                    # Reset state after suspend and give time to stabilize
                    debug_print("Resetting state after suspend, waiting for system to stabilize")
                    countdown_active = False
                    failed_count = INITIAL_FAILED_COUNT
                    countdown_remaining = SUSPEND_COUNTDOWN
                    
                    # Wait longer after resume to allow login and network stabilization
                    time.sleep(30)  # Give 30 seconds after resume
                    debug_print("Post-suspend stabilization period complete")
                    continue
            
            # Normal monitoring mode
            debug_print("Normal monitoring mode - checking host ping")
            if ping_host(HOST_TO_PING):
                # Successful ping - reset counters
                if failed_count < INITIAL_FAILED_COUNT:
                    debug_print(f"Host ping restored, resetting failed count from {failed_count} to {INITIAL_FAILED_COUNT}")
                failed_count = INITIAL_FAILED_COUNT
                countdown_active = False
                countdown_remaining = SUSPEND_COUNTDOWN
            else:
                # Failed ping
                failed_count -= 1
                debug_print(f"Host ping failed, failed count now: {failed_count}")
                
                if failed_count > 0:
                    # Show warning notification
                    send_notification("Power failure", f"Connection lost - {failed_count} attempts remaining")
                
                if failed_count <= 0:
                    # Check router as fallback before suspending
                    debug_print("Failed count reached 0, checking router fallback")
                    if ping_host(ROUTER_TO_PING):
                        debug_print("Router ping successful, resetting failed count")
                        failed_count = INITIAL_FAILED_COUNT  # Reset on router success
                        send_notification("Power failure", "Router accessible - assuming temporary issue")
                    else:
                        debug_print("Router ping also failed, starting suspend countdown")
                        send_notification("Power failure", f"Starting suspend countdown: {SUSPEND_COUNTDOWN}")
                        countdown_active = True
                        countdown_remaining = SUSPEND_COUNTDOWN
                        # Add delay before starting countdown to prevent immediate re-suspend
                        time.sleep(5)
                        continue
            
            time.sleep(LOOP_DELAY)
            
        except KeyboardInterrupt:
            debug_print("Received interrupt signal, shutting down")
            break
        except Exception as e:
            debug_print(f"Unexpected error in main loop: {e}")
            time.sleep(1)  # Prevent rapid error loops


if __name__ == "__main__":
    main()