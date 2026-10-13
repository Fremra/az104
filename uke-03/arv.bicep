@description('Taggen som arves fra resource groupen')
param tagName string = 'kostnadssted'

@description('Id-en til den innebygde policyen Inherit a tag from the resource group if missing')
param policyDefinitionId string

@description('Id-en til rollen Contributor, som policyen trenger for å endre tags')
param roleDefinitionId string

resource arvTag 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'arv-${tagName}'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: 'Arv taggen ${tagName} fra resource groupen'
    policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', policyDefinitionId)
    parameters: {
      tagName: {
        value: tagName
      }
    }
  }
}

resource arvRolle 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(arvTag.id, roleDefinitionId)
  properties: {
    principalId: arvTag.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
