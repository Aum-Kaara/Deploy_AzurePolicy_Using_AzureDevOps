targetScope = 'subscription'

@description('azure policy name')
param policyName string

@description('azure policy display name')
param policyDisplayName string

@description('azure policy description')
param policyDescription string

resource allowedlocationspolicy 'Microsoft.Authorization/policyDefinitions@2019-09-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    policyType: 'Custom'
    description: policyDescription
    metadata: {
      category: 'General'
    }
    mode: 'All'
    parameters: {
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed locations'
          description: 'The list of locations that can be specified when deploying resources.'
          strongType: 'location'
        }
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'location'
            notIn: '[parameters(\'allowedLocations\')]'
          }
          {
            field: 'location'
            notEquals: 'global'
          }
          {
            field: 'type'
            notEquals: 'Microsoft.AzureActiveDirectory/b2cDirectories'
          }
        ]
      }
      then: {
        effect: 'Deny'
      }
    }
  }
}
