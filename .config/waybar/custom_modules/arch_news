#!/bin/bash

# A bash script to fetch and display Arch Linux news for Waybar.

# Default values
days=7
active_color="#a6e3a1" 
inactive_color=""

# Argument parsing
if [[ "$1" =~ ^[0-9]+$ ]]; then
    if [ "$1" -le 0 ]; then
        jq -cn --arg msg "Error: Days must be a positive number" \
            '{"text": " ✗", "tooltip": $msg, "class": "arch-news-error"}'
        exit 1
    fi
    days="$1"
    shift
fi

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --active-color)
        active_color="$2"
        shift 2
        ;;
        --inactive-color)
        inactive_color="$2"
        shift 2
        ;;
        --version)
        echo "Arch News Waybar Module 1.0 (Bash version)"
        exit 0
        ;;
        *)
        jq -cn --arg msg "Error: Unknown option $1" \
            '{"text": " ✗", "tooltip": $msg, "class": "arch-news-error"}'
        exit 1
        ;;
    esac
done

# RSS feed URL
rss_url="https://archlinux.org/feeds/news/"

# Fetch the feed
feed_xml=$(curl -s -A "Waybar-ArchNews/1.0" "$rss_url")
if [ $? -ne 0 ]; then
    jq -cn --arg msg "Error: Failed to fetch RSS feed" \
        '{"text": " ✗", "tooltip": $msg, "class": "arch-news-error"}'
    exit 1
fi

if [ -z "$feed_xml" ]; then
    jq -cn --arg msg "Error: Empty RSS feed" \
        '{"text": " ✗", "tooltip": $msg, "class": "arch-news-error"}'
    exit 1
fi

# Cutoff date
cutoff_date=$(date -d "$days days ago" +%s)

# Process the feed with xmlstarlet and jq in a single pipeline
echo "$feed_xml" | xmlstarlet sel -t -m "//item" -o '{' \
    -o '"title":"' -v "title" -o '",' \
    -o '"pubDate":"' -v "pubDate" -o '"' \
    -o '}' -n | \
    jq -c -s --argjson cutoff "$cutoff_date" --arg active_color "$active_color" --arg inactive_color "$inactive_color" --arg days "$days" '
    # jq function to parse RFC-822 date format
    def parse_rfc822_date(date_str):
        # Example: "Sat, 21 Jun 2025 23:09:08 +0000"
        # Use strptime to parse the date string
        strptime("%a, %d %b %Y %H:%M:%S %z") | mktime;

    # Filter recent news
    . | map(select(.pubDate | try parse_rfc822_date(.) catch 0 >= $cutoff)) |
    
    # Generate the final JSON output
    {
        "count": length,
        "tooltip": if length > 0 then
                       map("\uf061 <span color=\"\($active_color)\">\(.title) (\(.pubDate | strptime("%a, %d %b %Y %H:%M:%S %z") | strftime("%Y-%m-%d %H:%M")))</span>") | .[0:3] | join("\n\n")
                   else
                       "No Arch Linux news in the last \($days) days"
                   end,
        "class": if length > 0 then "arch_news_active" else "arch_news_inactive" end,
        "percentage": if (length * 10) > 100 then 100 else (length * 10) end,
        "color": if length > 0 and $active_color != "" then $active_color
                 elif length == 0 and $inactive_color != "" then $inactive_color
                 else null end
    } |
    {
        "text": " \(.count)",
        "tooltip": .tooltip,
        "class": .class,
        "percentage": .percentage
    } + if .color != null then {color: .color} else {} end
'