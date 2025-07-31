from azure.identity import DefaultAzureCredential
from azure.ai.ml import MLClient
from azure.ai.ml.entities import ManagedOnlineEndpoint, ManagedOnlineDeployment
import uuid

# Replace with your Azure details
subscription_id = "<your-subscription-id>"
resource_group = "<your-resource-group>"
workspace_name = "<your-workspace-name>"
model_name = "<your-model-name>"
model_version = "<your-model-version>"

# Authenticate and create MLClient
credential = DefaultAzureCredential()
ml_client = MLClient(credential, subscription_id, resource_group, workspace_name)

# Create a unique endpoint name
endpoint_name = f"{model_name}-endpoint-{uuid.uuid4().hex[:4]}"

# Create endpoint
endpoint = ManagedOnlineEndpoint(
    name=endpoint_name,
    auth_mode="key"
)
ml_client.begin_create_or_update(endpoint).result()

# Create deployment
deployment = ManagedOnlineDeployment(
    name="blue",
    endpoint_name=endpoint_name,
    model=f"azureml:{model_name}:{model_version}",
    instance_type="Standard_DS3_v2",
    instance_count=1
)
ml_client.begin_create_or_update(deployment).result()

# Set traffic to deployment
ml_client.begin_update_endpoint(endpoint_name=endpoint_name, traffic={"blue": 100}).result()

print(f"Model deployed to Azure ML endpoint: {endpoint_name}")
