@description('Object-id-en til gruppen som skal ha rollen')
param groupId string

@description('Id-en til rollen, f.eks. Reader')
param roleDefinitionId string

resource readerForGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, groupId, roleDefinitionId)
  properties: {
    principalId: groupId
    principalType: 'Group'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
