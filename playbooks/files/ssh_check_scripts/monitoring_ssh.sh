#!/usr/bin/env bash
telegraf="localhost:8080/telegraf"
MEASUREMENT="ssh_connection_monitoring"
while (true)
do
  ./keep_ssh_connection.sh
  if $?!=0
  then
    telegraf_report connection_lost fail
  fi
done


function telegraf_report() {
  result=$1
  reason=$2
  infl_row="${MEASUREMENT},tgt_host=\"ecs_2\",reason=${reason} state=\"${result}\""
  status_code=$(curl -q -o /dev/null -X POST ${telegraf} -d "${infl_row}" -w "%{http_code}")
  if [[ "${status_code}" != "204" ]]; then
    echo "Can't report status to telegraf ($status_code)"
    exit 3
  fi
}
