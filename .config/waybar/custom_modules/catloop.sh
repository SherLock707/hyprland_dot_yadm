#!/usr/bin/env bash
set -euo pipefail

CPU_USAGE=0.0
SLEEP_AFTER=4

AWAKE_FRAMES=($(eval echo {A..E}))
SLEEP_FRAMES=($(eval echo {G..N}))

COUNT=0

read_cpu() {
  awk '/^cpu /{
    user=$2; nice=$3; sys=$4; idle=$5;
    active = user + nice + sys;
    total = active + idle;
    printf "%d %d\n", active, total;
    exit
  }' /proc/stat
}

read prev_active prev_total < <(read_cpu)

while true; do

  read active total < <(read_cpu)

  delta_active=$((active - prev_active))
  delta_total=$((total - prev_total))

  if [ "$delta_total" -le 0 ] || [ "$delta_active" -lt 0 ]; then
    utilization="0.0000"
  else
    utilization=$(awk -v a="$delta_active" -v t="$delta_total" 'BEGIN { printf "%.4f", (a / t) }')
  fi

  CPU_USAGE=$utilization	

	SPEED=$(awk -v u="$CPU_USAGE" 'BEGIN { printf "%.2f", 1 / (4 + (u * 100)) }')
	# clip minimum speed
	if (( $(echo "$SPEED < 0.03" | bc -l) )); then
		SPEED=0.03
	fi

	### MAKE THE CAT SLEEP IF CPU USAGE IS LOW after SLEEP_AFTER ###
	if (( $(echo "$CPU_USAGE < 0.02" | bc -l) )); then
		COUNT=$((COUNT + 1))
	else
		COUNT=0
	fi

	### CAT IS SLEEPING ###
	if [ $COUNT -ge $SLEEP_AFTER ]; then
		for s in "${SLEEP_FRAMES[@]}";do
			echo $s
			sleep $SPEED 
		done

	### CAT IS AWAKE ###
	else
		for i in "${AWAKE_FRAMES[@]}";do
			echo $i
			sleep $SPEED 
		done

	fi

  prev_active=$active
  prev_total=$total
done

# vim: set ts=2 sw=2
