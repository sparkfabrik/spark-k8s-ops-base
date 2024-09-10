#!/usr/bin/env bash

kga() {
  NAMESPACE="${1}"
  if [ -z "${NAMESPACE}" ]; then
    NAMESPACE=$(kubectl config view --minify --output 'jsonpath={..namespace}')
  fi
  if [ -z "${NAMESPACE}" ]; then
    echo "You must specify a namespace"
    echo "Usage: kga [NAMESPACE]"
  else
    echo -e "Show all resources in \e[1m\e[32m${NAMESPACE}\e[39m\e[0m namespace"
    kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n "${NAMESPACE}"
  fi
}

function print-basic-auth() {
  local CURRENT_NAMESPACE INGRESS FIRST_HOST SECRET USERNAME PASSWORD

  CURRENT_NAMESPACE="${1:-}"
  # If no namespace is provided, try to get the current one
  if [ -z "${CURRENT_NAMESPACE}" ]; then
    CURRENT_NAMESPACE="$(kubectl config view --minify -o jsonpath="{..namespace}")"
    # If there is no current namespace, use 'default'
    if [ -z "${CURRENT_NAMESPACE}" ]; then
      CURRENT_NAMESPACE="default"
    fi
  fi

  echo "Discovering configured ingresses in namespace: ${CURRENT_NAMESPACE}"

  for INGRESS in $(kubectl --namespace "${CURRENT_NAMESPACE}" get ingresses -o jsonpath='{.items[*].metadata.name}'); do
    FIRST_HOST="https://$(kubectl --namespace "${CURRENT_NAMESPACE}" get ingress "${INGRESS}" -o jsonpath="{.spec.rules[0].host}")"
    # We can't use the jsonpath directly because the 'auth-secret' annotation could be prefixed with custom prefix.
    SECRET="$(kubectl --namespace "${CURRENT_NAMESPACE}" get ingress "${INGRESS}" -o yaml | grep "ingress.kubernetes.io/auth-secret:" | awk '{print $2}')"
    if [ -z "${SECRET}" ]; then
      echo "No auth secret found for ingress ${INGRESS} (${FIRST_HOST})"
      continue
    fi
    # Remove the prefix from the secret name, if it is present
    SECRET="$(echo "${SECRET}" | cut -d"/" -f1)"
    USERNAME=$(kubectl --namespace "${CURRENT_NAMESPACE}" get secret "${SECRET}" -o jsonpath="{.data.username}" | base64 -d)
    PASSWORD=$(kubectl --namespace "${CURRENT_NAMESPACE}" get secret "${SECRET}" -o jsonpath="{.data.password}" | base64 -d)
    if [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ]; then
      echo "No auth credentials found in secret ${SECRET} (${INGRESS} - ${FIRST_HOST})"
      continue
    fi
    echo "Auth credentials for ingress ${INGRESS} (${FIRST_HOST}): ${USERNAME} / ${PASSWORD}"
  done

  echo "Done"
}
