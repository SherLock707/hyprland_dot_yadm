#!/usr/bin/env python3
# ----------------------------------------------------------------------------
# WAYBAR STORAGE MODULE
# ----------------------------------------------------------------------------
# Auto-detects mounted physical drives and displays usage in a sleek dashboard.
# Features:
# - Dynamic drive detection (ignores snaps, loops, etc.)
# - Real-time I/O speeds (Read/Write)
# - Drive temperature monitoring (requires lm_sensors/smartctl)
# - Health status via smartctl (requires sudo)
# ----------------------------------------------------------------------------

import json
import subprocess
import os
import psutil
import re
import time
import pickle
from collections import deque
import math
import pathlib

# ---------------------------------------------------
# CONFIGURATION
# ---------------------------------------------------
SSD_ICON = ""
HDD_ICON = "󰋊"
HISTORY_FILE = "/tmp/waybar_storage_history.pkl"
TOOLTIP_WIDTH = 45

# ---------------------------------------------------
# THEME & COLORS
# ---------------------------------------------------
try:
    import tomllib
except ImportError:
    tomllib = None

def load_theme_colors():
    # Tries to load from a standard waybar config location
    theme_path = pathlib.Path.home() / ".config/waybar/colors.toml"
    
    defaults = {
        "black": "#000000", "red": "#ff0000", "green": "#00ff00", "yellow": "#ffff00",
        "blue": "#0000ff", "magenta": "#ff00ff", "cyan": "#00ffff", "white": "#ffffff",
        "bright_black": "#555555", "bright_red": "#ff5555", "bright_green": "#55ff55",
        "bright_yellow": "#ffff55", "bright_blue": "#5555ff", "bright_magenta": "#ff55ff",
        "bright_cyan": "#55ffff", "bright_white": "#ffffff"
    }

    if not tomllib or not theme_path.exists():
        return defaults

    try:
        data = tomllib.loads(theme_path.read_text())
        colors = data.get("colors", {})
        normal = colors.get("normal", {})
        bright = colors.get("bright", {})
        return {**defaults, **normal, **{f"bright_{k}": v for k, v in bright.items()}}
    except Exception:
        return defaults

COLORS = load_theme_colors()

SECTION_COLORS = {
    "Storage": {"icon": COLORS["blue"], "text": COLORS["blue"]},
}

COLOR_TABLE = [
    {"color": COLORS["blue"],           "mem_storage": (0.0, 10),  "drive_temp": (0, 35)},
    {"color": COLORS["cyan"],           "mem_storage": (10.0, 20), "drive_temp": (36, 45)},
    {"color": COLORS["green"],          "mem_storage": (20.0, 40), "drive_temp": (46, 54)},
    {"color": COLORS["yellow"],         "mem_storage": (40.0, 60), "drive_temp": (55, 60)},
    {"color": COLORS["bright_yellow"],  "mem_storage": (60.0, 80), "drive_temp": (61, 70)},
    {"color": COLORS["bright_red"],     "mem_storage": (80.0, 90), "drive_temp": (71, 80)},
    {"color": COLORS["red"],            "mem_storage": (90.0,100), "drive_temp": (81, 999)}
]

def get_color(value, metric_type):
    if value is None: return "#ffffff"
    try: value = float(value)
    except ValueError: return "#ffffff"
    for entry in COLOR_TABLE:
        if metric_type in entry:
            low, high = entry[metric_type]
            if low <= value <= high: return entry["color"]
    return COLOR_TABLE[-1]["color"]

# ---------------------------------------------------
# HISTORY & UTILS
# ---------------------------------------------------
def format_compact(val, suffix=""):
    if val is None: return f"0{suffix}"
    try: val = float(val)
    except: return f"0{suffix}"
    if val < 1024: return f"{val:.0f}{suffix}"
    val /= 1024
    if val < 1024: return f"{val:.1f}K{suffix}"
    val /= 1024
    if val < 1024: return f"{val:.1f}M{suffix}"
    val /= 1024
    return f"{val:.1f}G{suffix}"

def load_history():
    try:
        with open(HISTORY_FILE, 'rb') as f:
            data = pickle.load(f)
            if not isinstance(data, dict): return {'io': {}, 'timestamp': 0}
            return data
    except: return {'io': {}, 'timestamp': 0}

def save_history(data):
    try:
        with open(HISTORY_FILE, 'wb') as f: pickle.dump(data, f)
    except: pass

# ---------------------------------------------------
# HARDWARE SENSORS
# ---------------------------------------------------
def get_drive_temp(mountpoint):
    """
    Attempts to find drive temperature via psutil -> device -> hwmon/smartctl.
    """
    try:
        partitions = psutil.disk_partitions()
        partition = next((p for p in partitions if p.mountpoint == mountpoint), None)
        if not partition: return None
        
        device_path = partition.device
        disk_name = os.path.basename(device_path)
        
        # Handle mapper/dm devices
        if disk_name.startswith("dm-"):
            try:
                slaves = os.listdir(f"/sys/class/block/{disk_name}/slaves")
                if slaves: disk_name = slaves[0] 
            except: pass

        # Handle NVMe
        if disk_name.startswith("nvme"):
            disk_name = re.sub(r'p\d+$', '', disk_name)
        else:
            disk_name = re.sub(r'\d+$', '', disk_name)
            
        # Try sensors command (lm_sensors)
        try:
            output = subprocess.check_output(["sensors", "-j"], text=True, stderr=subprocess.DEVNULL)
            data = json.loads(output)
            # Heuristic search in sensors output
            for key, val in data.items():
                # Check for nvme or scsi/sata adapter keys that might match
                if disk_name in key or (disk_name.startswith("nvme") and "nvme" in key):
                     for sub_k, sub_v in val.items():
                         if "temp1_input" in sub_k: return int(sub_v)
        except: pass

        # Fallback: smartctl (requires sudo NOPASSWD)
        try:
            cmd = ["sudo", "smartctl", "-A", f"/dev/{disk_name}", "-j"]
            result = subprocess.run(cmd, text=True, capture_output=True)
            if result.stdout:
                data = json.loads(result.stdout)
                return data.get("temperature", {}).get("current")
        except: pass

    except Exception:
        pass
    return None

def get_smart_info(mountpoint):
    """
    Fetches basic health info via smartctl.
    """
    health, lifespan, tbw = "N/A", "N/A", "N/A"
    try:
        partitions = psutil.disk_partitions()
        partition = next((p for p in partitions if p.mountpoint == mountpoint), None)
        if not partition: return health, lifespan, tbw
        
        disk_name = os.path.basename(partition.device)
        # Simplify disk name logic similar to above...
        
        cmd = ["sudo", "smartctl", "-a", "-j", f"/dev/{disk_name}"]
        result = subprocess.run(cmd, text=True, capture_output=True)
        if result.stdout:
            data = json.loads(result.stdout)
            passed = data.get("smart_status", {}).get("passed")
            health = "OK" if passed else "FAIL" if passed is False else "N/A"
            
            # NVMe specific
            if "nvme_smart_health_information_log" in data:
                nvme = data["nvme_smart_health_information_log"]
                used = nvme.get("percentage_used")
                if used is not None: lifespan = f"{max(0, 100 - used)}%"
                duw = nvme.get("data_units_written")
                if duw: tbw = f"{(duw * 512000) / 1e12:.1f} TB"
    except: pass
    return health, lifespan, tbw

# ---------------------------------------------------
# MAIN LOGIC
# ---------------------------------------------------
def get_drives():
    drives = []
    # Auto-detect physical drives
    for p in psutil.disk_partitions():
        if any(x in p.mountpoint for x in ['/snap', '/boot', '/docker', '/var', '/run', '/sys', '/proc', '/dev']): continue
        if any(x in p.device for x in ['/loop']): continue
        
        if p.fstype in ['ext4', 'btrfs', 'xfs', 'ntfs', 'vfat', 'apfs', 'zfs', 'exfat']:
            name = "Root" if p.mountpoint == "/" else os.path.basename(p.mountpoint)
            icon = SSD_ICON # Default icon
            drives.append((name, p.mountpoint, icon))
    return drives

def main():
    history = load_history()
    last_io = history.get('io', {})
    last_time = history.get('timestamp', 0)
    current_time = time.time()
    
    try: current_io = psutil.disk_io_counters(perdisk=True)
    except: current_io = {}

    drives = get_drives()
    storage_entries = []
    
    # Map mountpoints to device names for I/O lookup
    try:
        partitions = psutil.disk_partitions()
        mount_map = {p.mountpoint: os.path.basename(p.device) for p in partitions}
    except: mount_map = {}

    root_usage = 0

    for name, mountpoint, icon in drives:
        try:
            usage = psutil.disk_usage(mountpoint)
            used_pct = int(usage.percent)
            total_tb = usage.total / (1024**4)
            
            if mountpoint == "/": root_usage = used_pct
            
            temp = get_drive_temp(mountpoint)
            health, lifespan, tbw = get_smart_info(mountpoint)
            
            # I/O Speed
            r_spd, w_spd = 0, 0
            dev_name = mount_map.get(mountpoint)
            if dev_name and dev_name in current_io and dev_name in last_io:
                curr, prev = current_io[dev_name], last_io[dev_name]
                dt = current_time - last_time
                if dt > 0:
                    r_spd = (curr.read_bytes - prev.read_bytes) / dt
                    w_spd = (curr.write_bytes - prev.write_bytes) / dt

            storage_entries.append({
                "name": name, "icon": icon, "total": total_tb, "pct": used_pct,
                "temp": temp, "health": health, "lifespan": lifespan, "tbw": tbw,
                "r_spd": r_spd, "w_spd": w_spd
            })
        except: continue

    # ---------------------------------------------------
    # TOOLTIP
    # ---------------------------------------------------
    lines = []
    lines.append(f"<span foreground='{SECTION_COLORS['Storage']['text']}'>{SSD_ICON} Storage Dashboard</span>")
    lines.append(f"<span foreground='{COLORS['white']}'>{'─' * TOOLTIP_WIDTH}</span>")

    for entry in storage_entries:
        c_temp = get_color(entry['temp'], "drive_temp") if entry['temp'] else COLORS["bright_black"]
        c_usage = get_color(entry['pct'], "mem_storage")
        
        # Header: Icon Name Size
        size_str = f"{entry['total']:.1f}TB"
        lines.append(f"<span size='14000'><span foreground='{c_temp}'>{entry['icon']}</span> <span foreground='{COLORS['white']}'><b>{entry['name']}</b></span> - {size_str}</span>")
        
        # Temp & Health
        temp_str = f"{entry['temp']}°C" if entry['temp'] else "N/A"
        health_c = COLORS['green'] if entry['health'] == "OK" else COLORS['red']
        
        meta_info = []
        if entry['lifespan'] != "N/A": meta_info.append(f"Life: {entry['lifespan']}")
        if entry['tbw'] != "N/A": meta_info.append(f"TBW: {entry['tbw']}")
        meta_str = " | ".join(meta_info)
        
        lines.append(f" <span foreground='{c_temp}'>{temp_str}</span>  <span foreground='{health_c}'>♥ {entry['health']}</span>  <span size='small'>{meta_str}</span>")
        
        # Speed
        rs = format_compact(entry['r_spd'], "/s")
        ws = format_compact(entry['w_spd'], "/s")
        lines.append(f"<span size='small'>R: <span foreground='{COLORS['blue']}'>{rs}</span>  W: <span foreground='{COLORS['green']}'>{ws}</span></span>")
        
        # Bar
        bar_w = 25
        filled = int((entry['pct'] / 100) * bar_w)
        bar = f"<span foreground='{c_usage}'>{'█'*filled}</span><span foreground='{COLORS['bright_black']}'>{'░'*(bar_w-filled)}</span>"
        lines.append(f"{bar} {entry['pct']}%")
        lines.append("")

    lines.append(f"<span foreground='{COLORS['white']}'>{'┈' * TOOLTIP_WIDTH}</span>")
    lines.append("🖱️ LMB: File Manager")

    save_history({'io': current_io, 'timestamp': current_time})

    print(json.dumps({
        "text": f"{SSD_ICON} <span foreground='{get_color(root_usage,'mem_storage')}'>{root_usage}%</span>",
        "tooltip": "\n".join(lines),
        "markup": "pango",
        "class": "storage"
    }))

if __name__ == "__main__":
    main()