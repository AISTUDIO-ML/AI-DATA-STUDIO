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


The deployment ZIP is ready and available here:
📦 Download AI DATA STUDIO Deployment Package
It includes:
• Azure setup scripts (ACR, Key Vault, Container App with TEE)
• GitHub Actions CI/CD pipeline


🚀 Step-by-Step Deployment Plan on Azure TEE
1. Prepare the Docker Image
You already have a Dockerfile. Build and push it to Azure Container Registry (ACR):
az acr create --name honeypotzregistry --resource-group <your-resource-group> --sku Basic
az acr login --name honeypotzregistry
docker build -t honeypotzregistry.azurecr.io/ai-data-studio:latest .
docker push honeypotzregistry.azurecr.io/ai-data-studio:latest

⸻
2. Set Up Azure Confidential Containers (TEE)
Azure supports TEE via Confidential Containers using Confidential VMs and Kata Containers.
✅ Prerequisites:
• Azure CLI
• Confidential Compute-capable region (e.g., East US, West Europe)
• Subscription with Confidential VM quota
📦 Deploy with Confidential Container Group:
az containerapp env create \
  --name ai-data-studio-env \
  --resource-group <your-resource-group> \
  --location eastus \
  --enable-confidential-compute true

az containerapp create \
  --name ai-data-studio \
  --resource-group <your-resource-group> \
  --environment ai-data-studio-env \
  --image honeypotzregistry.azurecr.io/ai-data-studio:latest \
  --target-port 8000 \
  --ingress external \
  --registry-server honeypotzregistry.azurecr.io \
  --cpu 2 --memory 4Gi \
  --confidential-compute-cce-policy ConfidentialCompute

⸻
3. Secure the Environment
• Use Managed Identity for secure access to resources.
• Enable Azure Key Vault for secrets.
• Configure TLS/SSL for secure API access.
⸻
4. Monitor and Scale
• Use Azure Monitor and Log Analytics.
• Set up autoscaling rules based on CPU/memory usage.
⸻
✅ Optional Enhancements
• Add Azure Event Hubs for Kafka-like streaming.
• Integrate with Azure Machine Learning for model management.
• Use Azure DevOps or GitHub Actions for CI/CD.



• Virtual machines or containers inside Trusted Execution Environments (TEEs)
• Secure networking (private subnets, NSGs/security groups)
• Key management (Azure Key Vault / AWS KMS)
• Logging and monitoring (Azure Monitor / CloudWatch)
• Optional: AI model hosting (e.g., Azure ML / SageMaker)
⸻
🧰 What I’ll Include in the Terraform Setup
1. Azure Deployment
    • Confidential VM or SGX enclave
    • Azure Key Vault
    • Azure Monitor
    • Private networking
2. AWS Deployment
    • Nitro Enclaves or EC2 with enclave support
    • AWS KMS
    • CloudWatch
    • VPC with private subnets

☁️ Azure Deployment
• Uses Confidential VMs (Standard_DC2s_v2)
• Includes Azure Key Vault for secrets
• Configures Azure Monitor for logging and metrics
• Sets up private networking
📄 Download azure.tf
⸻
☁️ AWS Deployment
• Uses Nitro Enclaves on m6i.large EC2 instances
• Includes AWS KMS for key management
• Configures CloudWatch for logs and alarms
• Sets up VPC with private subnet and security group
📄 Download aws.tf

☁️ Azure DevOps Pipeline
• Deploys infrastructure using Terraform
• Authenticates with Azure using a service principal
• Deploys your AI model to Azure Machine Learning
📄 Download azure-pipeline.yml
⸻
☁️ GitHub Actions for AWS
• Deploys infrastructure using Terraform
• Uses boto3 to deploy your model to AWS SageMaker
📄 Download aws-pipeline.yml

☁️ Azure Workflow
• Deploys infrastructure using Terraform
• Deploys AI model to Azure Machine Learning
• Uses secrets for secure authentication
📄 Download azure.yml
⸻
☁️ AWS Workflow
• Deploys infrastructure using Terraform
• Deploys AI model to AWS SageMaker
• Uses GitHub Secrets for AWS credentials
📄 Download aws.yml
⸻
🔧 To Set Up in GitHub:
1. Place these files in your repo under .github/workflows/.
2. Add the following GitHub Secrets:
    • For Azure:
        • AZURE_CLIENT_ID
        • AZURE_CLIENT_SECRET
        • AZURE_SUBSCRIPTION_ID
        • AZURE_TENANT_ID
    • For AWS:
        • AWS_ACCESS_KEY_ID
        • AWS_SECRET_ACCESS_KEY
        • AWS_DEFAULT_REGION
3. Add your model deployment scripts:
    • azure/deploy_model_azureml.py
    • aws/deploy_model_sagemaker.py


🛠️ How to Use the Script
1. Make it executable
chmod +x create_azure_sp.sh

2. Run the script
./create_azure_sp.sh <your-subscription-id> [optional-resource-group-name]

• If you provide a resource group, the service principal will be scoped to it.
• If not, it will be scoped to the entire subscription.
⸻
🔐 Output
The script will print the values you need to add as GitHub Secrets:
• AZURE_CLIENT_ID
• AZURE_CLIENT_SECRET
• AZURE_TENANT_ID
• AZURE_SUBSCRIPTION_ID


🛠️ How to Use the Script
1. Make it executable
chmod +x create_aws_iam_user.sh

2. Run the script
./create_aws_iam_user.sh AIDataStudioUser

This will:
• Create an IAM user
• Generate access keys
• Attach the AdministratorAccess policy
• Output the credentials for GitHub Secrets
⸻
