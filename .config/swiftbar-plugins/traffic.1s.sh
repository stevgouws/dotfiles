#!/usr/bin/env bash

# <xbar.title>traffic</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Steven Gouws</xbar.author>
# <xbar.author.github>stevgouws</xbar.author.github>
# <xbar.desc>Simple traffic light system to indicate how seriously I don't want to be interrupted at any given time.</xbar.desc>
# <xbar.image>https://raw.githubusercontent.com/busterc/bitbar-cal/master/screenshot.png</xbar.image>
# <xbar.dependencies>bash</xbar.dependencies>
# <xbar.abouturl>https://github.com/busterc/bitbar-cal</xbar.abouturl>

# statuses=$(cat statuses.txt)

# echo $statuses
# echo "🔴 Do not disturb 🔴"

#!/usr/bin/env bash

# : "${SWIFTBAR_PLUGINS_PATH:?Need to set SWIFTBAR_PLUGINS_PATH}"

# 1) Read the key (e.g. RED) from current_status.txt:
key=$(<"$HOME/.config/swiftbar-plugins/traffic/current_status.txt")
key=${key//[$'\t\r\n ']/} # strip whitespace

# 2) Lookup in statuses.txt
status=$(grep -m1 "^${key}=" "$HOME/.config/swiftbar-plugins/traffic/statuses.txt" | cut -d= -f2-)

# 3) Check & output
if [[ -z $status ]]; then
  echo "No status found for key '$key'" >&2
  exit 1
fi

echo "$status"
echo "---"

# echo "$last_year"
# cal "$last_year" | while IFS= read -r i; do echo "--$i | trim=false font=courier"; done
# (cal -h "$year" 2>/dev/null || cal "$year") | while IFS= read -r i; do echo "$i | trim=false font=courier"; done
# cal "$next_year" | while IFS= read -r i; do echo "$i | trim=false font=courier"; done
