#---------------------------------------------------------------
# gitlab installation
#---------------------------------------------------------------
resource "kubernetes_manifest" "namespace_gitlab" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "gitlab"
    }
  }
}

# resource "kubernetes_manifest" "secret_gitlab_credentials" {
#   depends_on = [
#     kubernetes_manifest.namespace_gitlab  ]

#   manifest = {
#     "apiVersion" = "v1"
#     "kind" = "Secret"
#     "metadata" = {
#       "name" = "gitlab-credential"
#       "namespace" = "gitlab"
#     }
#     "data" = {
#       "username" = "${base64encode("gitlabadmin")}"
#       "password" = "${base64encode("mysecretgitpassword!")}"
#     }
#   }
# }

resource "terraform_data" "gitlab_setup" {
  depends_on = [
    kubernetes_manifest.namespace_gitlab
  ]

  provisioner "local-exec" {
    command = "./install.sh ${local.domain_name}"

    working_dir = "${path.module}/scripts/gitlab"
    interpreter = ["/bin/bash", "-c"]
  }

  provisioner "local-exec" {
    when = destroy

    command = "./uninstall.sh"

    working_dir = "${path.module}/scripts/gitlab"
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "kubectl_manifest" "ingress_gitlab" {
  depends_on = [
    kubernetes_manifest.namespace_gitlab
  ]

  yaml_body = templatefile("${path.module}/templates/manifests/ingress-gitlab.yaml", {
    GITLAB_DOMAIN_NAME = local.domain_name
  }
  )
}


