#!/bin/bash

df -h
read -e -p "Which device should we backup? " DEVICE
echo "Backing up ${DEVICE}"

ls $DEVICE 1>/dev/null 2>&1
EXISTENCE_CHECK=$?
if [ ! "${EXISTENCE_CHECK}" == "0" ] ; then
  echo "Device does not exist: ${DEVICE}"
  exit 1
fi

# Convert /dev/disk1s1 to /dev/rdisk1 (the "raw device name")
RAW_DEVICE=$(dirname ${DEVICE})/r$(basename ${DEVICE} | grep -oE "^[a-zA-Z]+[0-9]*" | head -1)
  
ls ${RAW_DEVICE} 1>/dev/null 2>&1
EXISTENCE_CHECK=$?
if [ ! "${EXISTENCE_CHECK}" == "0" ] ; then
  echo "Raw device does not exist: ${RAW_DEVICE}"
  exit 1
fi

read -p "What should we call this backup image [raspi-backup.img]?" IMAGE
if [ "${IMAGE}" == "" ] ; then
  IMAGE="raspi-backup.img"
fi

dd if=${RAW_DEVICE} of=${IMAGE} bs=1m
