# Azure 3-Tier Application with Terraform & Azure DevOps CI/CD

## Project Overview

This project demonstrates an **end-to-end Azure 3-tier application deployment** using **Terraform Infrastructure as Code (IaC)** and an automated **Azure DevOps CI/CD pipeline**.

The application is a simple **Goal Tracker** consisting of:

- **Frontend:** Node.js
- **Backend:** Go
- **Database:** Azure Database for PostgreSQL Flexible Server

The infrastructure is provisioned using modular Terraform code, while Azure DevOps automates application testing, Docker image creation, ACR publishing, deployment to Azure VM Scale Sets, and post-deployment validation.

The project also implements security and monitoring using **Application Gateway WAF, Azure Key Vault, Managed Identities, RBAC, private networking, Log Analytics, and Azure Monitor alerts**.

---

## Architecture

```text
                         Internet
                            |
                         Public IP
                            |
                 Application Gateway v2
                       + WAF Policy
                            |
                    Frontend VMSS
                   Node.js : Port 3000
                            |
                  Internal Load Balancer
                       Private IP
                            |
                     Backend VMSS
                     Go : Port 8080
                            |
               Azure Database for PostgreSQL
                       Port 5432
```

### Supporting Azure Services

```text
Azure Container Registry
        |
        +---- Frontend Docker Images
        |
        +---- Backend Docker Images

Azure Key Vault
        |
        +---- Database Username
        +---- Database Password
        +---- Database Host
        +---- Database Port
        +---- Database Name
        +---- SSL Configuration

Managed Identities
        |
        +---- Frontend VMSS → ACR Pull
        |
        +---- Backend VMSS  → ACR Pull
                            → Key Vault Secrets

Azure Monitor
        |
        +---- Log Analytics
        +---- Frontend CPU Alert
        +---- Backend CPU Alert
```

---

## Architecture Diagram

Add the project architecture diagram here:

```markdown
![Azure 3-Tier Architecture](docs/images/architecture.png)
```

The end-to-end application traffic flow is:

```text
User
 ↓
Internet
 ↓
Application Gateway + WAF
 ↓
Frontend VMSS
 ↓
Internal Load Balancer
 ↓
Backend VMSS
 ↓
PostgreSQL
```

Only the Application Gateway is Internet-facing. Backend and database communication remains within the private Azure network.

---

## Technology Stack

| Category | Technology |
|---|---|
| Cloud Platform | Microsoft Azure |
| Infrastructure as Code | Terraform |
| CI/CD | Azure DevOps Pipelines |
| Source Control | Azure Repos / GitHub |
| Containers | Docker |
| Container Registry | Azure Container Registry |
| Frontend | Node.js |
| Backend | Go |
| Database | Azure Database for PostgreSQL Flexible Server |
| Compute | Azure Virtual Machine Scale Sets |
| Load Balancing | Azure Application Gateway + Internal Load Balancer |
| Web Security | Web Application Firewall (WAF) |
| Secret Management | Azure Key Vault |
| Identity | Managed Identity / Workload Identity Federation |
| Authorization | Azure RBAC |
| Networking | VNet, Subnets, NSGs |
| Administration | Azure Bastion |
| Monitoring | Azure Monitor + Log Analytics |
| Alerting | Azure Monitor Metric Alerts |

---

# Infrastructure Architecture

## Virtual Network

The application uses a dedicated Azure Virtual Network:

```text
VNet: 10.0.0.0/16
```

Separate subnets are used for each application tier.

```text
Frontend Subnets
10.0.1.0/24
10.0.2.0/24

Backend Subnets
10.0.3.0/24
10.0.4.0/24

Database Subnets
10.0.5.0/24
10.0.6.0/24

Azure Bastion Subnet
10.0.7.0/24

Application Gateway Subnet
10.0.8.0/24
```

This separation provides better network isolation between application components.

---

## Frontend Tier

The frontend application is written in **Node.js** and packaged as a Docker container.

It runs on an Azure **Virtual Machine Scale Set (VMSS)**.

```text
Application Port: 3000
```

Application Gateway forwards incoming application traffic to the frontend VMSS.

The frontend communicates with the backend using the private internal load balancer.

```text
BACKEND_URL=http://<BACKEND-INTERNAL-LB>:8080
```

---

## Backend Tier

The backend application is written in **Go** and runs as a Docker container on a separate VM Scale Set.

```text
Application Port: 8080
```

The backend is not directly exposed to the Internet.

Frontend-to-backend communication passes through an Azure Internal Load Balancer.

The backend provides API endpoints including:

```text
GET    /goals
POST   /goals
DELETE /goals/:id
GET    /health
```

---

## Database Tier

The database layer uses:

**Azure Database for PostgreSQL Flexible Server**

```text
Database: goalsdb
Port: 5432
SSL: Required
```

The PostgreSQL server is accessed by the backend over the private Azure network.

Database credentials are not stored directly in the application source code.

---

# Security Implementation

Security was implemented at multiple layers.

## Application Gateway + WAF

Internet traffic enters the application through:

```text
Public IP
   ↓
Application Gateway v2
   ↓
Web Application Firewall Policy
   ↓
Frontend VMSS
```

The WAF provides Layer-7 protection for the Internet-facing application.

---

## Azure Key Vault

Sensitive database configuration is stored in Azure Key Vault.

Examples include:

```text
db-username
db-password
db-host
db-port
db-name
db-sslmode
```

The backend retrieves these values using its Azure Managed Identity.

No database password is hard-coded in the application or Docker image.

---

## Managed Identities

Separate managed identities are used for frontend and backend VM Scale Sets.

### Frontend Identity

```text
Frontend VMSS
     |
     +---- AcrPull
```

### Backend Identity

```text
Backend VMSS
     |
     +---- AcrPull
     |
     +---- Key Vault Secrets access
```

This eliminates the need to store Azure credentials on the VMs.

---

## Azure RBAC

Azure Role-Based Access Control is used to provide only the required permissions.

Examples:

```text
Azure DevOps Identity
        ↓
     AcrPush

Frontend VMSS Identity
        ↓
     AcrPull

Backend VMSS Identity
        ↓
     AcrPull
        +
Key Vault Secrets access
```

---

## Azure DevOps Authentication

Azure DevOps authenticates to Azure through an Azure Resource Manager service connection using:

**Workload Identity Federation (OIDC)**

```text
Azure DevOps
      ↓
OIDC Federation
      ↓
Microsoft Entra ID
      ↓
Azure Resources
```

This avoids maintaining a long-lived client secret for the CI/CD service connection.

---

# Terraform Infrastructure as Code

The complete Azure infrastructure is managed through Terraform.

The project uses reusable Terraform modules.

```text
infra/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── backend.tf
│
├── environments/
│   └── prod/
│       └── terraform.tfvars
│
└── modules/
    ├── networking/
    ├── acr/
    ├── keyvault/
    ├── database/
    ├── compute/
    ├── dns/
    └── monitoring/
```

Each module contains:

```text
main.tf
variables.tf
outputs.tf
```

This modular design improves maintainability and reusability.

---

## Terraform Remote State

Terraform state is stored remotely in Azure Storage rather than only on the deployment workstation.

```text
Terraform
    ↓
Azure Storage Account
    ↓
Blob Container
    ↓
Terraform State
```

This provides centralized state management for infrastructure deployments.

---

# Two-Phase Infrastructure Deployment

The project uses a two-phase deployment strategy.

This is required because VMSS instances need valid Docker images in ACR during initial provisioning.

## Phase 1 — Base Infrastructure

```hcl
deploy_compute = false
```

Terraform first creates the supporting infrastructure, including:

```text
Resource Group
Networking
Subnets
NSGs
Azure Container Registry
Key Vault
PostgreSQL
Managed Identities
Supporting Resources
```

Run:

```bash
terraform init

terraform validate

terraform plan \
  -var-file="environments/prod/terraform.tfvars" \
  -out=tfplan-phase1

terraform apply tfplan-phase1
```

---

## Push Initial Images to ACR

After ACR is created:

```bash
az acr login --name <ACR-NAME>
```

Build:

```bash
docker build -t <ACR-SERVER>/backend:latest ./backend
docker build -t <ACR-SERVER>/frontend:latest ./frontend
```

Push:

```bash
docker push <ACR-SERVER>/backend:latest
docker push <ACR-SERVER>/frontend:latest
```

---

## Phase 2 — Compute Infrastructure

Enable compute:

```hcl
deploy_compute = true
```

Then:

```bash
terraform plan \
  -var-file="environments/prod/terraform.tfvars" \
  -out=tfplan-phase2

terraform apply tfplan-phase2
```

Terraform then provisions the application compute components, including:

```text
Frontend VMSS
Backend VMSS
Internal Load Balancer
Application Gateway
WAF Policy
```

---

# Azure DevOps CI/CD

The project contains an end-to-end Azure DevOps YAML pipeline.

```text
Developer
    |
    | git push
    ↓
Azure Repos
    ↓
Azure DevOps Pipeline
    |
    ├── 1. Test
    |
    ├── 2. Build & Push
    |
    ├── 3. Deploy Backend
    |
    ├── 4. Deploy Frontend
    |
    └── 5. Validate
```

---

## Stage 1 — Test

Backend validation:

```bash
go mod download
go test ./...
```

Frontend validation:

```bash
npm ci
npm test
```

The pipeline stops if application validation fails.

---

## Stage 2 — Build and Push

After successful testing, Docker images are created for both application components.

```text
Backend Docker Image
Frontend Docker Image
```

Images are tagged using the Azure DevOps Build ID.

Example:

```text
backend:5
frontend:5
```

The pipeline also maintains:

```text
backend:latest
frontend:latest
```

Both images are pushed to Azure Container Registry.

Using the Build ID provides deployment traceability and makes rollback easier.

---

## Stage 3 — Deploy Backend

The pipeline discovers the backend VMSS and deploys:

```text
backend:<BuildId>
```

Deployment flow:

```text
Azure DevOps
     ↓
VMSS Run Command
     ↓
Backend Managed Identity
     ↓
ACR Login / Image Pull
     ↓
Key Vault Secret Retrieval
     ↓
Restart Backend Container
     ↓
/health Validation
```

The frontend deployment proceeds only after the backend deployment succeeds.

---

## Stage 4 — Deploy Frontend

The pipeline then deploys:

```text
frontend:<BuildId>
```

The frontend receives the internal backend URL:

```text
BACKEND_URL=http://<BACKEND-LB-IP>:8080
```

The container is restarted with the new application version and validated locally on port 3000.

---

## Stage 5 — Post-Deployment Validation

The final pipeline stage validates the public application.

Frontend validation:

```bash
curl http://<PUBLIC-IP>/
```

API validation:

```bash
curl http://<PUBLIC-IP>/api/goals
```

The pipeline is considered successful only when the deployed application responds correctly.

---

# Complete CI/CD Flow

```text
Developer Push
      ↓
Azure Repos
      ↓
Azure DevOps
      ↓
Application Tests
      ↓
Docker Build
      ↓
Versioned Image Tag
      ↓
Azure Container Registry
      ↓
Deploy Backend VMSS
      ↓
Backend Health Check
      ↓
Deploy Frontend VMSS
      ↓
Frontend Health Check
      ↓
Application Gateway
      ↓
Public Frontend Validation
      ↓
API Validation
      ↓
Deployment Successful
```

---

# Monitoring and Alerting

The project includes Azure-native monitoring.

## Log Analytics Workspace

Azure Log Analytics provides centralized monitoring capabilities for the environment.

## Azure Monitor Alerts

CPU metric alerts are configured for:

```text
Frontend VMSS
Backend VMSS
```

Alert condition:

```text
Average CPU > 80%
```

This provides basic operational monitoring of the application compute layer.

---

# Troubleshooting Experience

Several real deployment problems were identified and resolved while implementing the project.

## Application Gateway WAF Error

### Problem

Terraform returned an error indicating that direct WAF configuration on Application Gateway had been retired.

### Solution

A separate Azure Web Application Firewall Policy was created through Terraform and associated with Application Gateway.

---

## Application Gateway 502 Bad Gateway

### Problem

The public application initially returned:

```text
HTTP/1.1 502 Bad Gateway
```

Application Gateway backend health showed the frontend VMSS as unhealthy.

### Troubleshooting

The following were checked:

```text
Application Gateway backend health
VMSS provisioning state
Frontend private IP
Docker container status
Application port
NSG connectivity
Health probe configuration
```

After correcting the frontend container deployment, Application Gateway reported:

```text
Healthy
```

and the public endpoint returned:

```text
HTTP/1.1 200 OK
```

---

## Terraform Saved Plan Stale

### Problem

Terraform returned:

```text
Error: Saved plan is stale
```

### Cause

Terraform state changed after the saved plan was generated.

### Solution

A new Terraform plan was generated against the current state and then applied.

---

## Azure DevOps Frontend Test Failure

### Problem

The initial frontend pipeline failed because the package contained the default:

```text
Error: no test specified
```

### Solution

The frontend test command was changed to an appropriate application validation command.

---

## Azure DevOps YAML Indentation

### Problem

The deployment pipeline initially contained an indentation error.

### Solution

The YAML was validated before pushing:

```bash
python3 -c 'import yaml; yaml.safe_load(open("azure-pipelines.yml")); print("YAML syntax OK")'
```

The incorrect task indentation was fixed.

---

## Post-Deployment Public IP Validation

### Problem

The final pipeline stage initially returned an empty Application Gateway public IP, causing `curl` to fail.

### Solution

The Azure CLI query used to discover the public IP was corrected, after which the final validation stage completed successfully.

---

# Project Validation

The completed application was validated through the public endpoint.

Frontend:

```bash
curl -I http://<APPLICATION-PUBLIC-IP>
```

Expected:

```text
HTTP/1.1 200 OK
```

API:

```bash
curl http://<APPLICATION-PUBLIC-IP>/api/goals
```

Example successful response:

```json
{
  "goals": [
    {
      "ID": 4,
      "Name": "Complete Azure Terraform Project"
    }
  ],
  "success": true
}
```

This validates the complete request path:

```text
Internet
 ↓
Application Gateway
 ↓
Frontend
 ↓
Internal Load Balancer
 ↓
Backend
 ↓
PostgreSQL
```

---

# Screenshots

For portfolio documentation, the following screenshots provide the most useful evidence.

## 1. Successful Azure DevOps Pipeline

```markdown
![Azure DevOps Pipeline](docs/images/pipeline-success.png)
```

Shows all five stages successfully completed:

```text
Test
BuildPush
DeployBackend
DeployFrontend
Validate
```

## 2. Azure Resource Group

```markdown
![Azure Resources](docs/images/azure-resources.png)
```

Shows the infrastructure created through Terraform.

## 3. Application Gateway Backend Health

```markdown
![Application Gateway Health](docs/images/appgw-health.png)
```

Shows frontend VMSS backend health as:

```text
Healthy
```

## 4. Azure Container Registry

```markdown
![ACR Images](docs/images/acr-images.png)
```

Shows versioned frontend and backend Docker images.

## 5. Running Application

```markdown
![GoalTracker Application](docs/images/application.png)
```

Shows the GoalTracker application successfully accessible through Application Gateway.

---

# Repository Structure

```text
.
├── backend/
│   ├── main.go
│   ├── go.mod
│   ├── go.sum
│   └── Dockerfile
│
├── frontend/
│   ├── server.js
│   ├── package.json
│   ├── package-lock.json
│   ├── public/
│   └── Dockerfile
│
├── docker-local-deployment/
│
├── infra/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── backend.tf
│   │
│   ├── environments/
│   │   └── prod/
│   │
│   └── modules/
│       ├── networking/
│       ├── acr/
│       ├── keyvault/
│       ├── database/
│       ├── compute/
│       ├── dns/
│       └── monitoring/
│
├── azure-pipelines.yml
├── README.md
└── .gitignore
```

---

# Security Highlights

- Application Gateway is the primary Internet-facing application entry point.
- Application Gateway is protected by a WAF policy.
- Backend application is not directly Internet-facing.
- PostgreSQL communication uses the private Azure network.
- NSGs restrict traffic between application tiers.
- Database secrets are stored in Azure Key Vault.
- Managed Identities are used instead of storing Azure credentials on VMSS instances.
- Azure RBAC controls access to ACR and Key Vault.
- Azure DevOps authenticates through Workload Identity Federation.
- Docker images are stored in a private Azure Container Registry.
- Versioned image tags improve deployment traceability and rollback capability.

---

# Key Learning Outcomes

This project provided hands-on experience with:

- Designing Azure 3-tier architectures
- Terraform Infrastructure as Code
- Modular Terraform development
- Azure networking and subnet segmentation
- Docker containerization
- Azure Container Registry
- Azure VM Scale Sets
- Application Gateway and WAF
- Internal load balancing
- PostgreSQL Flexible Server
- Azure Key Vault
- Managed Identity
- Azure RBAC
- Workload Identity Federation
- Azure DevOps YAML pipelines
- CI/CD automation
- Versioned container deployments
- Post-deployment validation
- Azure Monitor and Log Analytics
- Troubleshooting real Azure deployment issues

---

# Interview Summary

> Designed and implemented an end-to-end Azure 3-tier application using Terraform and Azure DevOps. The Node.js frontend and Go backend run as Docker containers on separate Azure VM Scale Sets, with PostgreSQL as the private database tier. Application Gateway with WAF provides Internet-facing Layer-7 access, while an internal load balancer provides private frontend-to-backend communication. Azure Container Registry stores versioned Docker images, and Key Vault with Managed Identities and RBAC provides secure secret management. Azure DevOps uses Workload Identity Federation and automates application testing, Docker builds, ACR publishing, backend/frontend VMSS deployments, and post-deployment health/API validation. Azure Monitor and Log Analytics provide monitoring and CPU alerts.

---

# Project Status

**Completed**

```text
Terraform Infrastructure        ✅
Azure Networking                ✅
Application Gateway + WAF       ✅
Frontend VMSS                   ✅
Backend VMSS                    ✅
PostgreSQL                      ✅
Azure Container Registry        ✅
Azure Key Vault                 ✅
Managed Identity + RBAC         ✅
Azure Monitor / Log Analytics   ✅
Azure DevOps CI                 ✅
Azure DevOps CD                 ✅
Post-Deployment Validation      ✅
GitHub Documentation            ✅
```

---

## Author

**Neeraj Kumar**

Cloud & DevOps Project

Technologies demonstrated:

`Azure` `Terraform` `Azure DevOps` `Docker` `ACR` `VMSS` `Application Gateway` `WAF` `Key Vault` `PostgreSQL` `Azure Monitor` `CI/CD`
