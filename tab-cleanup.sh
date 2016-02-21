#!/usr/local/bin/bash
# Crontab cleanup script for Consul

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2016-02-21 @ 09:50:31
# VER : Version 1.0a


set -eu

HOST="${HOST:-localhost}"
PORT="${PORT:-8500}"

ADDR="http://${HOST}:${PORT}"

currDate="$(date +%s)"

curl -s "${ADDR}/v1/kv/tab?keys"                       | \
egrep -o '"([^"\\]|\\(["\\/bfnrt]|u[0-9a-fA-F]{4}))*"' | \
sed -e 's/^"//' -e 's/"$//'                            | \
while IFS=/ read -r tab taskId period schedDate ; do
  if ((schedDate + 2 * period < currDate )) ; then
    curl -s -X DELETE "${ADDR}/v1/kv/${tab}/${taskId}/${period}/${schedDate}"
  fi
done
