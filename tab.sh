#!/usr/local/bin/bash
# Crontab script for Consul

# CPR : Jd Daniel :: Ehime-ken
# MOD : 2016-02-21 @ 09:50:31
# VER : Version 1.0a


set -eu

HOST="${HOST:-localhost}"
PORT="${PORT:-8500}"
ADDR="http://${HOST}:${PORT}"

usage() {
  echo -e "Usage:\n  ${0##*/} <task id> [--period=<sec>] <command> ..." ; exit 1
}

function getLockOrDie() {
  local taskId="$1"
  local schedDate="$2"
  local period="$3"

  ret="$(curl -sS -X PUT -d "${HOSTNAME}" "${ADDR}/v1/kv/tab/${taskId}/${period}/${schedDate}?cas=0")"
  [[ "$ret" != "true" ]] && {
    [[ "$ret" != "false" ]] && {
       echo $ret
    }
    exit 1
  }
}

## parse args
[[ "$#" -lt 2 ]] && { usage ; }
taskId="$1" ; shift

case "$1" in
  --period)   period="$2"              ; shift 2;;
  --period=*) period="${1##--period=}" ; shift;;
  *) period=60 ;
esac

command=("$@")

## is wrong if cron started job late
schedDate="$(( ($(date '+%s') / period) * period ))"
getLockOrDie "$taskId" "$schedDate" "$period"

"${command[@]}" ## run...
