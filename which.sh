#!/bin/bash

# Determine which TTY appears to have a Raspberry Pi connected, if any.
TTY=$(dmesg | tac | grep -m1 -oE 'pl2303 converter now attached to tty[a-zA-Z\.0-9]+' | cut -d\  -f6)

echo /dev/${TTY}

