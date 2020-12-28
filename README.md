# Customer Service Monitoring
T-Systems solution for customer KPI monitoring for Open Telekom Cloud

[![Zuul Check](https://zuul.eco.tsi-dev.otc-service.com/api/tenant/eco/badge?project=opentelekomcloud-infra/customer-service-monitoring&pipeline=check&branch=devel)](https://zuul.eco.tsi-dev.otc-service.com/t/eco/builds?project=opentelekomcloud-infra/customer-service-monitoring)

This repository contains customer service monitoring test scenarios for 
**Open Telekom Cloud**

## Infrastructure
Infrastructure for test scenarios is built using Terraform and Ansible.

### Requirements
Existing scripts were checked to be working with:
 - Terraform 0.14
 - Ansible 2.9 (Python 3.7)

Installing terraform for Linux can be done using `install_terraform.sh`

### Build

Existing scenario infrastructure build can be triggered using `ansible-playbook playbooks/*_monitoring_setup.yml`

**!NB** Terraform is using OBS for storing remote state
Following variables have to be set: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

E.g. for scenario 2 following should be used:
```bash
cd scenarios
export AWS_ACCESS_KEY_ID=myau_id
export AWS_SECRET_ACCESS_KEY=sekret_myau
ansible-playbook "playbooks/dns_monitoring_setup.yml"
```
This script performs the following actions:
 1. Build required infrastructure using the configuration from `scenarios/dns_monitoring/` directory
 1. Run `dns_monitoring_setup.yml` playbook from `playbooks/` for created host

There are no credentials stored in `terraform.tfvars` file for the scenario. It is used file called "clouds.yaml" for authentication.
It must contain credentials and locate in one of the next places:
 1. `current directory`
 2. `~/.config/openstack`
 3. `/etc/openstack`
In case of you have more than one cloud you should set environment variable `OS_CLOUD`
See [openstack configuration](https://docs.openstack.org/python-openstackclient/pike/configuration/index.html) for details.

### Execution

Executed playbook also starts test/monitoring for created/refreshed infrastructure. \
Implementation of most tests can be found in [csm test utils](https://github.com/opentelekomcloud-infra/csm-test-utils) repository
