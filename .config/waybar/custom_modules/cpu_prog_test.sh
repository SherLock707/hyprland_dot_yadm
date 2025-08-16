#!/bin/bash

# Get CPU usage (or replace with any metric you want)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
progress=$(printf "%.0f" "$cpu_usage")

# Ensure progress is between 0 and 100
if [ "$progress" -gt 100 ]; then
    progress=100
elif [ "$progress" -lt 0 ]; then
    progress=0
fi

# Calculate stroke-dasharray for SVG circle
# Circle circumference = 2 * π * r (where r = 45)
circumference=283  # 2 * 3.14159 * 45 ≈ 283
progress_length=$((progress * circumference / 100))
remaining_length=$((circumference - progress_length))

# Determine color based on progress
if [ "$progress" -le 25 ]; then
    color="#a3be8c"
    class="low"
elif [ "$progress" -le 50 ]; then
    color="#ebcb8b"
    class="medium"
elif [ "$progress" -le 75 ]; then
    color="#d08770"
    class="high"
else
    color="#bf616a"
    class="critical"
fi

# Create SVG as base64 encoded data URI
svg="<svg width='20' height='20' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'>
  <circle cx='50' cy='50' r='45' fill='none' stroke='#3c3c3c' stroke-width='8' opacity='0.3'/>
  <circle cx='50' cy='50' r='45' fill='none' stroke='$color' stroke-width='8' 
          stroke-dasharray='$progress_length $remaining_length' 
          stroke-dashoffset='0' 
          transform='rotate(-90 50 50)'
          stroke-linecap='round'/>
</svg>"

# Encode SVG to base64
svg_encoded=$(echo "$svg" | base64 -w 0)

# Output with embedded SVG
echo "{\"text\":\"<img src='data:image/svg+xml;base64,$svg_encoded'/>\", \"tooltip\":\"CPU: ${progress}%\", \"class\":\"$class\", \"percentage\":$progress}"