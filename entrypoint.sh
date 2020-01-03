#!/bin/sh

set -e

if [ ! -z "$TZ" ]
then
  cp /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
fi

rm -f /tmp/copy.pid

if [ -z "$COPY_SRC" ] || [ -z "$COPY_DEST" ]
then
  echo "INFO: No COPY_SRC and COPY_DEST found. Starting rclone config"
  rclone config $RCLONE_OPTS
  echo "INFO: Define COPY_SRC and COPY_DEST to start copy process."
else
  # COPY_SRC and COPY_DEST setup
  # run copy either once or in cron depending on CRON
  if [ -z "$CRON" ]
  then
    echo "INFO: No CRON setting found. Running copy once."
    echo "INFO: Add CRON=\"0 0 * * *\" to perform copy every midnight"
    /copy.sh
  else
    if [ -z "$FORCE_COPY" ]
    then
      echo "INFO: Add FORCE_COPY=1 to perform a copy upon boot"
    else
      /copy.sh
    fi

    # Setup cron schedule
    crontab -d
    echo "$CRON /copy.sh >>/tmp/copy.log 2>&1" > /tmp/crontab.tmp
    if [ -z "$CRON_ABORT" ]
    then
      echo "INFO: Add CRON_ABORT=\"0 6 * * *\" to cancel outstanding copy at 6am"
    else
      echo "$CRON_ABORT /copy-abort.sh >>/tmp/copy.log 2>&1" >> /tmp/crontab.tmp
    fi
    crontab /tmp/crontab.tmp
    rm /tmp/crontab.tmp

    # Start cron
    echo "INFO: Starting crond ..."
    touch /tmp/copy.log
    touch /tmp/crond.log
    crond -b -l 0 -L /tmp/crond.log
    echo "INFO: crond started"
    tail -F /tmp/crond.log /tmp/copy.log
  fi
fi

