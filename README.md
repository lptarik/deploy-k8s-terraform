# Deploying to Kubernetes via Terraform in AWS EKS

You should be able to run kubectl in your local machine adjust your .kube/config 

## Configure kubectl
```
aws eks --region <your region> update-kubeconfig --name <your eks cluster name>
```
## Terraform apply
```
terraform init
terraform apply

```
## See load balancer DNS name 
```
kubectl get svc 
```
## Destroy
```
terraform destroy
```
