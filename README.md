# AI-DATA-STUDIO

📘 AI DATA STUDIO Deployment Guide (Azure + GitHub Actions)
🔐 GitHub Secrets Setup
To enable CI/CD deployment via GitHub Actions, add the following secrets to your GitHub repository:
1. AZURE_CREDENTIALS
    • Create a service principal:
    • az ad sp create-for-rbac --name "github-actions-deployer" --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID> --sdk-auth

    • Copy the JSON output and add it as a secret named AZURE_CREDENTIALS.
2. ACR_USERNAME and ACR_PASSWORD
    • Get credentials:
    • az acr credential show --name honeypotzregistry

    • Add the username and passwords[0].value as secrets.
⸻
🚀 Running Azure CLI Scripts
1. Login to Azure
1. az login

2. Run setup scripts
2. chmod +x scripts/*.sh
./scripts/setup_acr.sh
./scripts/setup_keyvault.sh
./scripts/deploy_container_app.sh

⸻
📊 Enable Monitoring, Logging, and Autoscaling
1. Enable Log Analytics
1. az monitor log-analytics workspace create \
  --resource-group honeypotz-rg \
  --workspace-name ai-data-studio-logs

2. Attach to Container App
2. az containerapp update \
  --name ai-data-studio \
  --resource-group honeypotz-rg \
  --logs-workspace-id <workspace-id> \
  --logs-workspace-key <workspace-key>

3. Enable Autoscaling
3. az containerapp revision set-mode \
  --name ai-data-studio \
  --resource-group honeypotz-rg \
  --mode multiple

az containerapp update \
  --name ai-data-studio \
  --resource-group honeypotz-rg \
  --min-replicas 1 \
  --max-replicas 5 \
  --scale-rule-name http-rule \
  --scale-rule-type http \
  --scale-rule-http-concurrency 50
