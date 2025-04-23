## DevOps Architecture for Azure Web App Deployment


### 📐 Architecture Overview

This solution includes:

- **Developer Workflow**:
  - Developers push code to a GitHub repository.
  - GitHub Actions triggers a multi-stage CI/CD pipeline on every push to the `main` branch.

- **CI/CD Pipeline**:
  - **Stage 1: Infrastructure Provisioning**
    - Uses Bicep to provision:
      - Resource Group (RG)
      - App Service Plan
      - Web App (Linux)
      - Azure Container Registry (ACR)
      - Storage Account (for assets/logs)
      - Application Insights (monitoring)
  
  - **Stage 2: Build and Test**
    - Installs dependencies via `npm install`
    - Runs tests using `npm test`
    - Builds the app with `npm run build`

  - **Stage 3: Release & Deploy**
    - Builds and tags a Docker image with the Git SHA
    - Pushes the image to ACR
    - Deploys the container to Azure Web App using `azure/webapps-deploy@v2`

---

### 🔐 Security Practices

- Uses **OIDC Workload Identity Federation** for GitHub → Azure authentication (no secrets in pipeline)
- ACR credentials are retrieved securely at runtime via `az acr credential show`
- App settings (like Docker registry credentials) are injected securely

---

### 🔁 Rollback Strategy

- Docker images are versioned by commit SHA
- To roll back: redeploy a previously pushed Docker tag via Azure CLI or by Publishing previous Release on Azure DevOps

---

### 🌈 Blue/Green and Canary Deployment Readiness

- Azure App Service Slots can support Blue/Green deployment by using Deployment Slots 'Staging' 'Production'
- Canary releases possible with Azure Front Door and traffic routing

---

### 📊 Monitoring & Observability

- Integrated with **Application Insights** for logs, metrics, traces
- Azure Monitor Alerts can be configured for:
  - High error rate
  - Slow response times
  - Low availability
- Alert channels can include Teams, Slack, or email

---

### 📁 Repo Structure

```bash
📁 infra/
├── main.bicep            # Azure Infrastructure as Code (IaC)
├── main.parameters.json  # Deployment parameters

📁 pipeline/
└── azure-pipelines.yml   # GitHub Actions CI/CD pipeline
    azure-pipelines-devops.yml  # Azure DevOps CI/CD pipeline

📁 diagram/
└── architecture.drawio   # Architecture diagram

📄 answers.md              # DevOps strategy Q&A
```

---



