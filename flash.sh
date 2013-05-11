#!/bin/bash

DEFAULT_IMAGE_FILE_URL="http://downloads.raspberrypi.org/images/raspbian/2013-02-09-wheezy-raspbian/2013-02-09-wheezy-raspbian.zip"

echo "Searching for available disk images..."
find ~ -name "*.img" -type f -size +1048576 | xargs ls -l {}
read -e -p "Which image should be use? " IMAGE_FILE
if [ "$IMAGE_FILE" == "" ] ; then
  echo "No image file selected; downloading one from ${DEFAULT_IMAGE_FILE_URL}"
  wget $DEFAULT_IMAGE_FILE_URL
  unzip $(basename $DEFAULT_IMAGE_FILE_URL)
  IMAGE_FILE=$(basename $DEFAULT_IMAGE_FILE_URL .zip).img
fi
echo "Using $IMAGE_FILE"

ls $IMAGE_FILE 1>/dev/null 2>&1
EXISTENCE_CHECK=$?
if [ ! "$EXISTENCE_CHECK" == "0" ] ; then
  echo  "Image file does not exist: $IMAGE_FILE"
  exit 1
fi

df -h
read -e -p "Which device should we flash? " DEVICE
echo "Flashing $DEVICE"

ls $DEVICE 1>/dev/null 2>&1
EXISTENCE_CHECK=$?
if [ ! "$EXISTENCE_CHECK" == "0" ] ; then
  echo "Device does not exist: $DEVICE"
  exit 1
fi

# Convert /dev/disk1s1 to /dev/rdisk1 (the "raw device name")
RAW_DEVICE=$(dirname $DEVICE)/r$(basename $DEVICE | grep -oE "^[a-zA-Z]+[0-9]*" | head -1)
  
ls $RAW_DEVICE 1>/dev/null 2>&1
EXISTENCE_CHECK=$?
if [ ! "$EXISTENCE_CHECK" == "0" ] ; then
  echo "Raw device does not exist: $RAW_DEVICE"
  exit 1
fi

diskutil info $RAW_DEVICE | grep -E "Protocol: +Secure Digital" 1>/dev/null 2>&1
SD_CARD_CHECK=$?
if [ ! "$SD_CARD_CHECK" == "0" ] ; then
  echo "Raw device does not appear to be an SD card: $RAW_DEVICE"
  exit 1
fi

sudo diskutil unmount $DEVICE
if [ "$?" == "0" ] ; then
  sudo dd bs=1m if=$IMAGE_FILE of=$RAW_DEVICE
  # chug chug chug chug chugs
  
  if [ "$?" == "0" ] ; then
    # Done, now unmount so we can eject
    diskutil unmountDisk $DEVICE
    
    if [ "$?" == "0" ] ; then
      echo "Done"
      exit 0
    fi
  fi
fi

echo "Writing image file to SD card failed"
exit 1
