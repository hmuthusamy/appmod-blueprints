#!/bin/bash
  set -e

  INSTALL_YAML="./gitlab-install.yaml"
  GITLAB_DIR="."
  CHART_VERSION="9.2.1"
  DOMAIN_NAME=$1

  echo "# GITLAB INSTALL RESOURCES" >${INSTALL_YAML}
  echo "# This file is auto-generated with 'gitlab/install.sh'" >>${INSTALL_YAML}
  sed "s/DOMAIN_NAME/${DOMAIN_NAME}/g" ${GITLAB_DIR}/values.yaml.tmpl > ${GITLAB_DIR}/values.yaml

  helm repo add gitlab --force-update https://charts.gitlab.io/
  helm repo update
  helm template my-gitlab gitlab/gitlab -f ${GITLAB_DIR}/values.yaml --version ${CHART_VERSION} --namespace gitlab>>${INSTALL_YAML}
  sed -i.bak '3d' ${INSTALL_YAML}

  # Filter out problematic resources with unsupported API versions
  yq eval 'select(.kind != "PodDisruptionBudget" and .kind != "HorizontalPodAutoscaler")' ${INSTALL_YAML} > ${INSTALL_YAML}.filtered
  mv ${INSTALL_YAML}.filtered ${INSTALL_YAML}

  kubectl apply -n gitlab -f ${INSTALL_YAML}