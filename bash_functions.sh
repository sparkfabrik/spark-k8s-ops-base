#!/bin/sh

function kga () {
  if [ -z "${1}" ]; then
    echo "You must specify a namespace"
    echo "Usage: ${0} <NAMESPACE>"
  else
    kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n "${1}"
  fi
}
