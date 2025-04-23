
## 1. How would you handle secrets and credentials securely?

I use Azure OIDC Workload Identity Federation via the `azure/login@v2` action, which avoids using long-lived secrets and credentials in GitHub. This allows GitHub Actions to obtain a temporary and secure access token.

Additionally:
- Secrets like `AZURE_CLIENT_ID`, `TENANT_ID`, and `SUBSCRIPTION_ID` are stored in `GitHub Secrets`.
- ACR credentials are retrieved dynamically using `az acr credential show` and are not stored persistently.
- I would also use Library from Azure DevOps to store secrets and enviroment variables

---

## 2. How would you roll back if a deployment breaks production?

There are several strategies:

- The pipeline uses versioned Docker images (`${{ github.sha }}`) in ACR, so i can roll back simply by redeploying a previous image using:

  ```bash
  az webapp config container set \
    --name webapp-<client>-<env> \
    --resource-group RG-<client>-<env> \
    --docker-custom-image-name acr.azurecr.io/latest:<previous_sha>
  ```

---

## 3. How would you enable blue/green or canary deployments?

### Blue/Green:
- Create two deployment slots in the Azure Web App: `staging` and `production`.
- Deploy to the `staging` slot and run validations.
- If everything is fine, perform a **slot swap** using:

  ```bash
  az webapp deployment slot swap \
    --name webapp-<client> \
    --resource-group RG-<client> \
    --slot staging \
    --target-slot production
  ```

### Canary:
- I would set up traffic routing via Azure Front Door or Application Gateway.
- I Would route a percentage of traffic to the new slot for monitoring before completing the rollout.

---

## 4. How would you monitor and alert for app issues post-deployment?

Application Insights is already integrated, so:

- Enable live metrics, traces, and logs from App Service.
- Set up Azure Monitor alerts based on metrics like:
  - Error rate > 5%
  - Response time > 1 second
  - Availability < 99%
  - CPU > 60%

- Integrate alerts with channels like Microsoft Teams, Slack, or email.
- Optionally add manual instrumentation in the code (`appInsights.trackException`, `trackEvent`, etc.) for better observability.

---
