import boto3
import time

sagemaker = boto3.client("sagemaker", region_name="us-east-1")

model_name = "ai-data-studio-model"
endpoint_config_name = f"{model_name}-config"
endpoint_name = f"{model_name}-endpoint"

# Create model
sagemaker.create_model(
    ModelName=model_name,
    PrimaryContainer={
        "Image": "<your-container-image-uri>",
        "ModelDataUrl": "<your-s3-model-artifact-url>",
    },
    ExecutionRoleArn="<your-sagemaker-execution-role-arn>"
)

# Create endpoint config
sagemaker.create_endpoint_config(
    EndpointConfigName=endpoint_config_name,
    ProductionVariants=[{
        "VariantName": "AllTraffic",
        "ModelName": model_name,
        "InstanceType": "ml.m5.large",
        "InitialInstanceCount": 1
    }]
)

# Deploy endpoint
sagemaker.create_endpoint(
    EndpointName=endpoint_name,
    EndpointConfigName=endpoint_config_name
)

print(f"Model deployed to SageMaker endpoint: {endpoint_name}")
