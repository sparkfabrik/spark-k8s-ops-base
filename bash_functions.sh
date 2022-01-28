#!/bin/sh

function kga () {
  NAMESPACE="${1}"
  if [ -z "${NAMESPACE}" ]; then
    NAMESPACE=$(kubectl config view --minify --output 'jsonpath={..namespace}')
  fi
  if [ -z "${NAMESPACE}" ]; then
    echo "You must specify a namespace"
    echo "Usage: ${0} [NAMESPACE]"
  else
    echo -e "Show all resources in \e[1m\e[32m${NAMESPACE}\e[39m\e[0m namespace"
    kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n "${NAMESPACE}"
  fi
}
