#!/bin/bash

# Find hwmonX where 'name' is 'amdgpu'
hwmon=$(basename "$(find /sys/class/hwmon/hwmon*/name -exec grep -l amdgpu {} + 2>/dev/null | head -n1 | xargs -r dirname)")

# Fallback to hwmon5 if detection fails
[[ -z "$hwmon" ]] && hwmon="hwmon5"

# Create or update symlink in home directory
ln -sfn "/sys/class/hwmon/$hwmon" "$HOME/.amdgpu_hwmon"
