#!/usr/bin/env bash
# This is script starting continuous monitoring of load balancer nodes

start_dir=$( pwd )
local_dir=$( cd $( dirname "$0" ); pwd )
project_root=$1
echo "Project root: ${project_root}"


scenario_dir=$(cd "${local_dir}/.."; pwd)
echo "Scenario directory: ${scenario_dir}"
cd "${scenario_dir}" || exit 1
source ./post_build.sh

cd "${project_root}" || exit 1

function run_test() {
    python ${local_dir}/continuous.py "${LOADBALANCER_PUBLIC_IP}" --telegraf https://csm.outcatcher.com
}

log_path="/var/log/scenario1"
sudo mkdir -p ${log_path}
username=$(whoami)
sudo chown ${username} ${log_path}

run_test >> ${log_path}/execution.log &
