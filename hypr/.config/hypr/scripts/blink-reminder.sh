#!/bin/bash

# Configuration (in seconds)
WAIT_TIME=1200 # 20 minutes between reminders
BLINK_TIME=120 # How long the sphere will blink

while true; do
  # Hidden state
  echo '{"text": "", "class": "hidden"}'
  sleep $WAIT_TIME

  # Blinking state (outputs a Unicode sphere: ●)
  echo '{"text": "", "class": "blinking"}'
  sleep $BLINK_TIME
done
