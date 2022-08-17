#!/bin/bash

cp alertmanager.yml alertmanager.yml_backup
oc -n openshift-monitoring get secret alertmanager-main -o jsonpath="{.data.alertmanager\.yaml}" | base64 -d > alertmanager.yml
