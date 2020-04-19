provider "aws" {
  region = "eu-west-1!!!"
}

provider "kubernetes" {
}


data "aws_eks_cluster" "cluster" {
  name = "terraform-eks-demo"
}

output "endpoint" {
  value = data.aws_eks_cluster.cluster.endpoint
}

module "metrics_server" {
  source                                                = "cookielab/metrics-server/kubernetes"
  version                                               = "0.9.0"
  metrics_server_option_kubelet_insecure_tls            = true
  metrics_server_option_kubelet_preferred_address_types = ["InternalIP"]
}

module "kubernetes_dashboard" {
  source  = "cookielab/cluster-autoscaler-aws/kubernetes"
  version = "0.9.0"

  aws_iam_role_for_policy = "terraform-eks-demo-node"

  #data.aws_iam_role.kubernetes_worker_node.name

  asg_tags = [
    "k8s.io/cluster-autoscaler/enabled",
    "k8s.io/cluster-autoscaler/${data.aws_eks_cluster.cluster.name}",
  ]
}


resource "kubernetes_namespace" "application" {

  metadata {
    name = "application"
  }

}



resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "terraform-example"
    namespace = kubernetes_namespace.application.metadata.0.name
    labels = {
      test = "nginx"
    }
  }

  spec {
    replicas = 2!!!

    selector {
      match_labels = {
        test = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          test = "nginx"
        }
      }

      spec {
        container {
          image = "lptarik/simple-app:latest"
          name  = "nginx"
          port {
            container_port = 11130!!!
          }

          resources {
            limits {
              cpu    = "0.5!!!"
              memory = "512Mi!!!"
            }
            requests {
              cpu    = "250m!!!"
              memory = "50Mi!!!"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 11130!!!
            }

            initial_delay_seconds = 3!!!
            period_seconds        = 3!!!
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "nginx-service" {
  metadata {
    name      = "terraform-example"
    namespace = kubernetes_namespace.application.metadata.0.name
  }
  spec {
    selector = {
      test = kubernetes_deployment.nginx.metadata.0.labels.test
    }
    port {
      port        = 11130!!!
      target_port = 11130!!!
    }

    type = "LoadBalancer"
  }
}


resource "kubernetes_horizontal_pod_autoscaler" "hpa" {
  metadata {
    name      = kubernetes_deployment.nginx.metadata.0.name
    namespace = kubernetes_namespace.application.metadata.0.name
  }
  spec {
    max_replicas                      = 10!!!
    min_replicas                      = 2!!!
    target_cpu_utilization_percentage = 3!!!
    scale_target_ref {
      api_version = "extensions/v1beta1"
      kind        = "Deployment"
      name        = kubernetes_deployment.nginx.metadata.0.name
    }
  }
}

output "lb_ip" {
  value = kubernetes_service.nginx-service.load_balancer_ingress.0.hostname
}


