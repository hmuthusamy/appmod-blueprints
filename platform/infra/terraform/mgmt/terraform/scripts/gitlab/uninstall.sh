#!/bin/bash
  set -e

  INSTALL_YAML="./scripts/gitlab/gitlab-install.yaml"
  kubectl delete -f ${INSTALL_YAML} --namespace gitlab >/dev/null 2>&1 || true
  rm -f ${INSTALL_YAML} ${GITLAB_DIR}/values.yaml ${INSTALL_YAML}.bak