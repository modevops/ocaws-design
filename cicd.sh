#!/bin/bash
################################################################################
# Provisioning script to deploy CI/CD on an OpenShift environment            #
################################################################################
oc new-project dev --display-name="Tasks - Dev"
oc new-project stage --display-name="Tasks - Stage"
oc new-project cicd --display-name="CI/CD"
oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n dev
oc policy add-role-to-user edit system:serviceaccount:cicd:jenkins -n stage
oc process -f https://raw.githubusercontent.com/OpenShiftDemos/openshift-cd-demo/origin-3.6/cicd-template.yaml | oc create -f - -n cicd
sleep 15
oc delete pod install-gogs
oc delete pods -l app=gogs
oc process -f https://raw.githubusercontent.com/OpenShiftDemos/openshift-cd-demo/origin-3.6/cicd-template.yaml | oc create -f - -n cicd
