@description('Object-id-en til gruppen som skal ha rollen')
param groupId string

@description('Reader. Id-en til en innebygd rolle er den samme i alle tenanter')
param roleDefinitionId string = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

resource readerForGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, groupId, roleDefinitionId)
  properties: {
    principalId: groupId
    principalType: 'Group'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
