@description('Taggen som kreves på alle ressurser')
param tagName string = 'kostnadssted'

@description('Id-en til den innebygde policyen Require a tag on resources')
param policyDefinitionId string

@description('Default håndhever policyen. DoNotEnforce evaluerer bare')
@allowed([
  'Default'
  'DoNotEnforce'
])
param enforcementMode string = 'Default'

resource krevTag 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'krev-${tagName}'
  properties: {
    displayName: 'Krev taggen ${tagName}'
    policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionId)
    enforcementMode: enforcementMode
    parameters: {
      tagName: {
        value: tagName
      }
    }
  }
}
