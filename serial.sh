#!/bin/bash

# Disconnect anybody current connected
TTY=$($(dirname $0)/which.sh)
echo ${TTY}
PID=$(ps -lt ${TTY} | grep "${TTY}" | sed -e 's/^[[:space:]]*//' | tr -s ' ' | cut -d' ' -f2)
if [ "$PID" != "" ] ; then
  echo "Currently connected PID: $PID"
  read -n1 -p "Disconnect? [yN] " DISCONNECT
  echo
  
  if [ "$DISCONNECT" == "y" ] ; then
    kill $PID
    echo "Attempted to kill PID $PID"
  else
    echo "Okay, but I don't think this is going to work..."
  fi
  sleep 2
fi

screen ${TTY} 115200

