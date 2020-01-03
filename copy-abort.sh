#!/bin/sh

set -e

if [ ! -f /tmp/copy.pid ]
then
  echo "INFO: No outstanding copy $(date)"
else
  echo "INFO: Stopping copy pid $(cat /tmp/copy.pid) $(date)"

  pkill -P $(cat /tmp/copy.pid)
  kill -15 $(cat /tmp/copy.pid)
  rm -f /tmp/copy.pid
fi
