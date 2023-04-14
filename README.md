# Java app challenge

Sample-java-app dockerized and deployed to Kubernetes cluster with bunch of infrastructure tools with the help of ArgoCD.


</br>

## Navigation

---

- [Java app challange](#java-app-challange)
  - [Navigation](#navigation)
  - [TL&DR](#tl&dr)
  - [Setup](#setup)
  - [Step1](#step1)
  - [Step2](#step2)
  - [Step3](#step3)
  - [Overview](#overview)

</br>

## TL&DR
---
Kubernetes has been created by the project called [**noobspray**](https://github.com/alperencelik/noobspray.git) which is inspired by kubespray. The cluster has been created with 4 nodes. 1 master and 3 workers. Then ArgoCD has been installed to that cluster with helm install. After the installation of ArgoCD, I have created an applicationset.yaml which will be creating the applications based on the current structure of the gitops folder. The applicationset.yaml will be creating the all applications.

## Setup
---
After cluster creation for bootstrapping the applications some commands required to be executed are the following:

```
cd /gitops/argo-cd
# Install ArgoCD
helm install argocd ./ -f initial-values.yaml -n argocd
# Create applicationsets for new ArgoCD applications
kubectl apply -f ../applicationset.yaml
```

## Step1
---
I have used the existing repo called [**sample-java-app**](https://github.com/SampleJavaApp/app) as a reference but make some addition on that to extend some functionality. I have cloned the existing repository and copied to /app folder in the repo. I have used the same folder structure as the existing repository. I have added the following files to the repository.

1. Dockerfile
2. Jenkinsfiles (build.Jenkinsfile and deploy.Jenkinsfile)
3. Also did some changes to enable metrics in the existing code.
<br> </br>

## Step2
---
### Provisioning the infrastructure
---
Instead of using the Vagrantfile I have used my existing homelab setup which is based on Proxmox/KVM. I have created 4 VM's with different amount of resources. For the base images of VM's I choose centos7-minimal images since that was lying around in my homelab. To create VM's I have created a terraform script which can be found in the **/proxmox-terraform** folder. As the current variables for the terraform script it will be creating 4 VM's with the following resources.

- kubernetes-master-1 (4 vCPU, 4GB RAM, 32GB NVMe SSD) 
- kubernetes-worker-1 (4 vCPU, 16GB RAM, 32GB NVMe SSD) 
- kubernetes-worker-2 (4 vCPU, 16GB RAM, 32GB NVMe SSD) 
- kubernetes-worker-3 (4 vCPU, 16GB RAM, 32GB NVMe SSD) 

### Creating the Kubernetes cluster
---
To create a production-ready Kubernetes cluster I used my project called [**noobspray**](https://github.com/alperencelik/noobspray.git) which is inspired by kubespray. It does the same job with kubespray but noobspray is more static, dependent on the OS release and version. Currently I have support for Centos, Fedora and Ubuntu as distros but the only tested version is Centos 7. The biggest different between kubespray and noobspray is that noobspray is using kube-vip for control plane where kubespray uses nginx-proxies deployed to worker nodes. To create a cluster the required documentation can be found in the project's [readme](https://github.com/alperencelik/noobspray/blob/main/README.md). 


### Deploying the infrastructure 
---
Deployment of each application to cluster has been accomplished by using ArgoCD which is declarative GitOps tool. I have created directory called /gitops in the repo which contains the structure for the applications. The installation of the ArgoCD has been initiated by using the helm but after installing the ArgoCD, it will be managing itself thanks to the current gitops folder structure. Installation of ArgoCD also can be accomplished by using other tools like Crossplane or so but I think this discussion can be go up to the chicken and egg problem. After the installation of ArgoCD, I have created an applicationset.yaml which will be creating the applications based on the current structure of the gitops folder. The applicationset.yaml will be creating the following applications.

0. ArgoCD \
    After the argoCD installation and applicationset.yaml creation, the ArgoCD will create an application called "argocd" and will reconcile the /argocd folder in the repo. That way every change in the **/argocd** folder will be reflected in the ArgoCD itself.

1. Infra Apps 
    1. Argo Rollouts \
        Argo Rollouts deployed for managing canary deployments. It is a great tool for managing different deployment strategies and it is also a part of ArgoCD.

    2. Cert-manager \
        Cert-manager is used for certificate management. All the tls certificates for Ingress objects has been created by using cert-manager. I have created an clusterissuer.yaml which is creating a self-signed issuer for the cluster with the dns challenge. I have used cloudflare for the dns challenge and the credentials are stored in the repo as a Sealedsecret. The issuer will be creating the certificates for my existing domain so every ingress object will have a valid certificate.

    3. Ingress-nginx \
        Ingress-nginx is deployed as Ingress controller for Kubernetes which using NGINX as a reverse proxy and load balancer. 

    4. Jenkins \
        Jenkins is deployed as a CI/CD tool for the cluster. All the required configurations has been tried to done with values file. The only thing that I have done manually was the creating the pipeline jobs to build&deploy. To deploy the jenkins only for worker-3 I've tainted the node and added a toleration to the jenkins deployment. Details can be found in the values file and the description below.

    5. Kyverno \
        Kyverno is a policy engine which can be used for validating and mutating Kubernetes resources. I have created a policy which is checking the resource requests for the deployments. If the deployment does not have resource requests, the policy will be rejecting the deployment.

    6. Local-path-provisioner \
        Local-path-provisioner is a provisioner for Kubernetes which is using the local storage of the nodes. I have used local-path-provisioner as a storage backend and it's needed for persistent volumes.

   7. Metallb \
        Metallb is a load balancer implementation for bare metal Kubernetes clusters, using standard routing protocols. I have used metallb with address pool to assign IP address to Load Balancer typed services. I have created a configmap which is creating a pool of IP addresses for the load balancer.

    8. Monitoring-system \
        Monitoring-system is a monitoring stack which is using Prometheus, Grafana and Loki and also ElasticSearch and Kibana. I've used kube-prometheus-stack which includes Prometheus Operator, Prometheus, Alertmanager, Grafana and so for monitoring needs. In addition to that I've added Loki stack as a log aggregation and log management so in that way logs and the metrics can be shown in same dashboards in Grafana. I've also added ElasticSearch and Kibana for the log management.
        
        By default elasticsearch versions >= 8.0.0 supports TLS encryption and I've enabled it by using the values file but it didn't work so I tried with the version 7.16.1 which doesn't have TLS encryption enabled by default. As a workaround I did the authentication for Kibana in ingress side and enabled basic authentication for Kibana's ingress. 

        To have better view for monitoring I've enabled service monitors for each application and also created a dashboard for each application. I've also used the default dashboard's from kube-prometheus-stack. Also for sample-java-app I've enabled the metrics endpoint for the application and created a service monitor for it.            

    9. Sealed-secrets \
        Sealed-secrets is another way to manage secrets in Kubernetes. It is using asymmetric encryption to encrypt the secrets and store them in the git repository. I have created a sealedsecret.yaml which is creating a sealed secret for the cloudflare credentials.


## Step3
---
### Deploying the application
---
The java application has been deployed to the cluster by using ArgoCD also. To seperate the application pods to the worker nodes I've used topologySpreadConstraints for the deployment. Also added some probes to make sure that application receives requests after it succeed on probes which means ready to serve.     

1. Sample Java App
    For the java application I have created helm chart which is creating the deployment, rollout, service and ingress for the application. I have created a values file which is creating the application with the specified settings.
    
    For canary deployments I have used Argo Rollouts which is a part of ArgoCD. I have created the rollout.yaml inside the helm chart so the rollout can be toggled on/off by using the values file. Toggling on the rollout will be creating the rollout object and will be deleting the deployment object. The rollout object will be creating the canary deployment and will be managing the traffic between the canary and the stable deployment.

    The build and deploy pipelines for the project is placed on **/app** directory. The build pipeline is responsible for building the docker image and pushing it to the docker registry(it's dockerhub in this case). The deploy pipeline is responsible for updating the image version on the gitops repo so the ArgoCD will be deploying the new version of the application. I've used GIT_COMMIT sha as a container image tag but any other variable like BUILD_ID can be used for that as well. 

    Deploy pipelines also can be happen with Kubernetes module of ansible but I would like to have all of the applications managed decleratively with GitOps principles so in deployment pipeline with the help of ansible's Git submodule I'm updating the sample-java-app's image tag in the repo. Since deploy pipeline needs push to the repo it requires a github personal access token which should be placed in cluster. I've called the secret as "github-token".

    For the custom-validation webhook part I've tried to create a validation webhook for that but it didn't work quite well so as a workaround I've created a policy for Kyverno which is checking the resource requests for the deployments. If the deployment does not have resource requests, the policy will be rejecting the deployment. It's actually meeting the requirements on case study but it's validating on Kyverno's validation webhook instead of mine.

