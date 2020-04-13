# Deploying to Kubernetes via Terraform AWS EKS

You should be able to run kubectl in your local machine adjust your .kube/config 

```
## Terraform apply
```
terraform init
terraform apply
```

## Configure kubectl
```
aws eks --region eu-west-1 update-kubeconfig --name terraform-eks-demo
```
## See load balancer DNS name 
```
kubectl get svc 
```
## Destroy
```
terraform destroy
```