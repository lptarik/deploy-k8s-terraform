provider "kubernetes" {
}

resource "kubernetes_namespace" "application" {

  metadata {
    name = "application"
  }

}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "terraform-example"
    labels = {
      test = "nginx"
    }
  }

  spec {
    replicas = 2

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
          image = "lptarik/nginx:latest"
          name  = "nginx"

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "nginx-service" {
  metadata {
    name = "terraform-example"
  }
  spec {
    selector = {
      test = kubernetes_deployment.nginx.metadata.0.labels.test
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

#output "lb_ip" {
 # value = kubernetes_service.nginx-service.load_balancer_ingress.0.ip
#}


