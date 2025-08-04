#!/bin/bash

BATTERY="BAT0" 
AC_ADAPTER="AC0" 

CAPACITY=$(cat "/sys/class/power_supply/${BATTERY}/capacity")
STATUS=$(cat "/sys/class/power_supply/${BATTERY}/status")

if [ "$STATUS" = "Charging" ]; then
    ICON=""
elif [ "$CAPACITY" -ge 90 ]; then
    ICON=""
elif [ "$CAPACITY" -ge 60 ]; then
    ICON=""
elif [ "$CAPACITY" -ge 30 ]; then
    ICON=""
else
    ICON=""
fi

echo "${ICON} ${CAPACITY}%"
