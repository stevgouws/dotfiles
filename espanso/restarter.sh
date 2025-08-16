#!/usr/bin/env bash
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

LOGFILE="/Users/stevengouws/.config/espanso/restarter.log"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# capture both stdout and stderr, *and* record exit code
raw="$(/usr/local/bin/espanso status 2>&1)"
code=$?

# DEBUG: write exactly what we got
# echo "$TIMESTAMP — DEBUG raw: ‘$raw’ (code $code)" >> "$LOGFILE"

if [[ $code -ne 0 ]] || [[ "$raw" =~ "not running" ]]; then
  /usr/local/bin/espanso start 2>&1
  outcome="Espanso was not running → started"
else
  outcome="Espanso already running"
fi

echo "$TIMESTAMP — $outcome — status: ‘$raw’" >> "$LOGFILE"
