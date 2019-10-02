#!/usr/bin/env bash

start_dir=$( pwd )
local_dir=$( cd $( dirname "$0" ); pwd )
project_root=$( bash ${local_dir}/../../core/get_project_root.sh )
echo "Project root: ${project_root}"


scenario_dir=$(cd "${local_dir}/.."; pwd)
echo "Scenario directory: ${scenario_dir}"
cd "${scenario_dir}" || exit 1
terraform init || exit $?

ws_name="single"

terraform workspace select ${ws_name} || terraform workspace new ${ws_name} || exit $?

bastion_eip="80.158.3.174"

function prepare() {
    cur_dir=$(pwd)
    cd ${scenario_dir}
    bash ./pre_build.sh
    file=tmp_state
    terraform state pull > ${file} || exit $?
    source "${project_root}/.venv/bin/activate"
    python3 "${project_root}/scenarios/core/create_inventory.py" ${file} --name "scenario1-single"
    deactivate
    source ./post_build.sh
    cd ${cur_dir}
}


function start_stop_rand_node() {
    if [[ $1 == "stop" ]]; then
        playbook=scenario1_stop_server_on_random_node.yml
    else
        playbook=scenario1_setup.yml
    fi
    cur_dir=$( pwd )
    cd ${project_root}
    ansible-playbook -i inventory/prod playbooks/${playbook}
    cd ${cur_dir}
}

function telegraf_report() {
    result=$1
    reason=$2
    echo Report result: ${result}\(${reason}\)
    public_ip="$( curl http://ipecho.net/plain -s )"
    infl_row="lb_down_test,client=${public_ip},reason=${reason} state=\"${result}\""
    status_code=$( curl -q -o /dev/null -X POST https://csm.outcatcher.com/telegraf -d "${infl_row}" -w "%{http_code}" )
    if [[ "${status_code}" != "204" ]]; then
        echo "Can't report status to telegraf ($status_code)"
        exit 3
    fi
}

version=0.1
archive=lb_test-${version}.tgz
if [[ ! -e ${archive} ]]; then
    wget -q -O ${archive} https://github.com/opentelekomcloud-infra/csm-test-utils/releases/download/v${version}/lb_test-${version}-linux.tar.gz
    tar xf ${archive}
fi

prepare
echo Preparation Finished
echo Bastion at ${BASTION_PUBLIC_IP}
echo LB at ${LOADBALANCER_PUBLIC_IP}
start_test="./load_balancer_test ${LOADBALANCER_PUBLIC_IP}"
echo Starting test...

function test_should_pass() {
    res=$?
    if [[ ${res} != 0 ]]; then
        telegraf_report fail ${res}
        echo Test failed
        exit ${res}
    fi
    echo Test passed
}

${start_test}
test_should_pass

start_stop_rand_node stop
${start_test}
test_result=$?
if [[ ${test_result} == 0 ]]; then
    telegraf_report fail multiple_nodes
    exit ${test_result}
elif [[ ${test_result} != 101 ]]; then
    telegraf_report fail ${test_result}
    exit ${test_result}
fi

start_stop_rand_node start
${start_test}
test_should_pass
telegraf_report pass 0
