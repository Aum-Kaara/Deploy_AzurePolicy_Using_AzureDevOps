# Deploy_AzurePolicy_Using_AzureDevOps
How to deploy Azure Policy Bicep Template using Azure DevOps

# ARM Template
```
{
  "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
       "policyName": {
      "type": "string"
    },
      "policyDisplayName": {
      "type": "string"
    },
      "policyDescription": {
      "type": "string"
    }
  },
  "resources": [
      {
          "type": "Microsoft.Authorization/policyDefinitions",
          "name": "[parameters('policyName')]",
          "apiVersion": "2019-09-01",
          "properties": {
              "displayName": "[parameters('policyDisplayName')]",
              "policyType": "Custom",
              "description": "[parameters('policyDescription')]",
              "metadata": {
                  "category": "General"
              },
              "mode": "All",
              "parameters": {
                  "allowedLocations": {
                      "type": "Array",
                      "metadata": {
                          "displayName": "Allowed locations",
                          "description": "The list of locations that can be specified when deploying resources.",
                          "strongType": "location"
                      }
                  }
              },
              "policyRule": {
                  "if": {
                      "allOf": [
                          {
                              "field": "location",
                              "notIn": "[[parameters('allowedLocations')]" //Use an additional left bracket here, so the function is not invoked in the ARM template itself
                          },
                          {
                              "field": "location",
                              "notEquals": "global"
                          },
                          {
                              "field": "type",
                              "notEquals": "Microsoft.AzureActiveDirectory/b2cDirectories"
                          }
                      ]
                  },
                  "then": {
                      "effect": "Deny"
                  }
              }
          }
      }
  ]
}


```

# Azure DevOps Pipeline YML Code

```
name: $(Build.DefinitionName)_$(SourceBranchName)_$(date:yyyyMMdd)$(rev:.r)

pool:
  vmImage: 'windows-latest'

stages:
  - stage: Deploy_ARM_Template
    displayName: Deploy_ARM_Template
    jobs:
    - job: 
      steps: 
      - task: CopyFiles@2
        inputs:
          SourceFolder: '$(System.DefaultWorkingDirectory)\iac\'
          Contents: '**'
          TargetFolder: '$(Build.ArtifactStagingDirectory)\artifacts'
          
      - task: PublishPipelineArtifact@1
        inputs:
          targetPath: '$(Build.ArtifactStagingDirectory)\artifacts'
          ArtifactName: 'artifact'
          publishLocation: pipeline
        
      - task: AzureResourceManagerTemplateDeployment@3
        inputs:
          deploymentScope: 'Subscription'
          azureResourceManagerConnection: 'Subscription Name Here'
          subscriptionId: 'subscription ID Here'
          location: 'East US'
          templateLocation: 'Linked artifact'
          csmFile: '$(Build.ArtifactStagingDirectory)\artifacts\policy.json'
          csmParametersFile: '$(Build.ArtifactStagingDirectory)\artifacts\policy.parameters.json'
          deploymentMode: 'Incremental'
```
