# Tactful-DevOps-Challange

🚀 Azure AKS Voting App Challenge

This repository contains the infrastructure and application code for a simple, resilient, three-tier voting application deployed on Azure Kubernetes Service (AKS).

1. ⚙️ Setup & Deployment Instructions

This project uses Terraform to provision the cloud infrastructure (AKS, ACR, Networking) and Helm to deploy the microservices (Vote App, Worker, Result App) and their dependencies (PostgreSQL, Redis).

A. Infrastructure Provisioning (Terraform)

The following steps set up the necessary Azure resources.

Prerequisites

    Azure CLI installed and authenticated (az login).

    Terraform CLI installed.

    A pre-configured Service Principal (SP) with Contributor role on the target Azure Subscription.

Execution

    Initialize Terraform: Navigate to the root of your Terraform configuration directory.
    Bash

terraform init

Plan the Deployment: Review the infrastructure changes Terraform intends to make.
Bash

terraform plan -out=voting-infra.tfplan

Apply Changes: Execute the plan to provision AKS, ACR, VNet, and all related networking components.
Bash

terraform apply "voting-infra.tfplan"

    Output: Terraform will output the AKS Cluster Name and the Azure Container Registry (ACR) Login Server.

Configure kubectl: Merge the new cluster credentials into your local Kubernetes configuration.
Bash

    az aks get-credentials --resource-group <RG_NAME> --name <AKS_CLUSTER_NAME>

B. Application Deployment (GitHub Actions & Helm)

The applications are deployed using a GitHub Actions CI/CD pipeline, ensuring secure image builds and consistent deployment via Helm.

1. Image Build & Push (GitHub Actions)

The workflow defined in .github/workflows/main.yml builds the three images (vote, worker, result) and pushes them to your ACR.

    Trigger: Push code to the main branch.

    Authentication: Uses a dedicated Azure Service Principal (via the secure AZURE_CREDENTIALS secret) for Azure login and ACR authentication.

2. Install/Upgrade Helm Charts

Once images are pushed to ACR, the workflow updates the Helm release, applying the application manifests, services, and probes.

    Dependency Aliases: Ensure the critical external name services (db and redis) are created in the app namespace to allow inter-service communication across namespaces.

    Install/Upgrade: The pipeline uses helm upgrade --install to deploy all services, referencing the new image tags pushed in the previous step.

2. 💡 Design Decisions & Trade-Offs

The following choices were made to meet the security, resilience, and operational requirements of the challenge:

A. Secret Management: Sealed Secrets

Decision	Trade-Offs	Why it was Chosen
Sealed Secrets for postgres-secret.yaml	Requires external tool (kubeseal) and manual Master Key Backup for DR/rebuild scenarios.	Speed and GitOps: Fastest path to encrypt secrets for Git storage without needing a complex Azure Key Vault and CSI Driver setup, meeting the time constraint.
Master Key Backup	High risk if the backup file is lost or compromised.	Resilience: Mandatory step to ensure the rebuilt cluster can decrypt old secrets, ensuring the application can restore state after infrastructure destruction.

B. Resilience & Monitoring: Liveness/Readiness Probes

Decision	Trade-Offs	Why it was Chosen
Combined Readiness Probe (Sidecar)	Increased Pod complexity and resource usage (extra busybox container).	Reliability: Since application code could not be modified to check external dependencies (Redis/Postgres), the sidecar running nc -z provides a robust, independent check of dependency reachability, ensuring traffic only goes to fully functional Pods.
Liveness Probe: httpGet or tcpSocket	Doesn't check deep application health (e.g., query failure), only process status.	Simplicity: Sufficient to detect hard crashes or blocked event loops (for Node.js), ensuring basic process uptime without requiring complex custom health endpoints.

C. External Access: NGINX Ingress Controller

Decision	Trade-Offs	Why it was Chosen
NGINX Ingress with ingressClassName	Requires managing Azure NSG/Load Balancer external connectivity rules.	Flexibility: Provides centralized Layer 7 routing (Host-based, path-based) and the ability to terminate SSL, which is far superior to using multiple separate LoadBalancer services.
Ingress Class Fix (kubernetes.io/ingress.class vs. ingressClassName)	Initial configuration errors due to controller version mismatch.	Compatibility: Ensured the Ingress resource was processed by the correct controller instance (the one running in the ngnix namespace), resolving the initial external access issue.

D. Inter-Service Communication

Decision	Trade-Offs	Why it was Chosen
ExternalName Service Aliases (db and redis in the app namespace)	Adds an extra Kubernetes Service resource layer.	Code Stability: Allows the application code to use simple, hardcoded hostnames (db and redis), while Kubernetes handles the complex namespace-to-namespace routing to the actual database deployments.