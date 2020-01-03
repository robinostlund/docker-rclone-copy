#!/bin/sh

set -e

echo "INFO: Starting copy.sh pid $$ $(date)"

if [ `lsof | grep $0 | wc -l | tr -d ' '` -gt 1 ]
then
  echo "WARNING: A previous copy is still running. Skipping new copy command."
else

echo $$ > /tmp/copy.pid

if test "$(rclone ls $COPY_SRC $RCLONE_OPTS)"; then
  # the source directory is not empty
  # it can be copyed without clear data loss
  echo "INFO: Starting rclone copy $COPY_SRC $COPY_DEST $RCLONE_OPTS $COPY_OPTS"
  rclone copy $COPY_SRC $COPY_DEST $RCLONE_OPTS $COPY_OPTS

  if [ -z "$CHECK_URL" ]
  then
    echo "INFO: Define CHECK_URL with https://healthchecks.io to monitor copy job"
  else
    wget $CHECK_URL -O /dev/null
  fi
else
  echo "WARNING: Source directory is empty. Skipping copy command."
fi

rm -f /tmp/copy.pid

fi
