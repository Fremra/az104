// Samme lagringskonto som azuredeploy.json, skrevet i Bicep.
// Fasit for steg 7 i labben: lag din egen med `az bicep decompile` først, og sammenlign etterpå.

@description('The name of the Azure storage resource')
@minLength(3)
@maxLength(24)
param storageName string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'

resource storage 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageName
  tags: {
    displayName: storageName
  }
  location: resourceGroup().location
  kind: 'StorageV2'
  sku: {
    name: storageSKU
  }
}

output storageEndpoint object = storage.properties.primaryEndpoints
