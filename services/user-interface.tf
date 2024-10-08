resource "kubernetes_manifest" "ingress_ui" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = var.ui_service_name
      namespace = "default"
      annotations = {
        "alb.ingress.kubernetes.io/scheme" = "internet-facing"
        "alb.ingress.kubernetes.io/target-type" = "ip"
        "alb.ingress.kubernetes.io/subnets" = join(",", local.public_subnet_ids)
      }
    }
    spec = {
      ingressClassName = "alb"
      rules = [
        {
          http = {
            paths = [
              {
                pathType = "Prefix"
                path = "/"
                backend = {
                  service = {
                    name = var.ui_service_name
                    port = {
                      number = 8080
                    }
                  }
                }
              },
            ]
          }
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "service_ui" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = var.ui_service_name
      namespace = "default"
    }
    spec = {
      selector = {
        app = var.ui_service_name
      }
      ports = [
        {
          port     = 8080
          protocol = "TCP"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "service_account_ui" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = var.ui_service_name
      "namespace" = "default"
    }
  }
}

resource "kubernetes_manifest" "deployment_ui" {
  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      labels = {
        app = var.ui_service_name
      }
      name      = var.ui_service_name
      namespace = "default"
    }
    spec = {
      replicas = 1
      selector = {
        matchLabels = {
          app = var.ui_service_name
        }
      }
      template = {
        metadata = {
          labels = {
            app = var.ui_service_name
          }
        }
        spec = {
          containers = [
            {
              env = [
                {
                  name  = "LISTEN_ADDR"
                  value = "0.0.0.0:8080"
                },
                {
                  name  = "NAME"
                  value = var.ui_service_name
                },
                {
                  name  = "MESSAGE"
                  value = "Hello from the UI service!"
                }
              ]
              image = var.default_container_image
              name  = var.ui_service_name
              ports = [
                {
                  containerPort = 8080
                },
              ]
              resources = {
                limits = {
                  cpu    = "500m"
                  memory = "512Mi"
                }
                requests = {
                  cpu    = "250m"
                  memory = "256Mi"
                }
              }
              command = ["sh", "-c"]
              args = [
                "/app/fake-service"
              ]
            },
          ]
          serviceAccountName = var.ui_service_name
        }
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "hpa_ui" {
  metadata {
    name      = var.ui_service_name
    namespace = "default"
  }
  spec {
    max_replicas = 5
    min_replicas = 1
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = var.ui_service_name
    }
    target_cpu_utilization_percentage = 70
  }
}