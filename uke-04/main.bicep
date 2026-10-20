@description('Redundansen til storage accounten')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
])
param skuName string = 'Standard_LRS'

@description('Soft delete: slettede blober, containere og filshare kan hentes tilbake i 7 dager')
param softDelete bool = false

@description('Versjonering: gamle versjoner av en blob tas vare på når den skrives over')
param versjonering bool = false

resource sa 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'st${uniqueString(resourceGroup().id)}'
  location: resourceGroup().location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: sa
  name: 'default'
  properties: {
    isVersioningEnabled: versjonering
    deleteRetentionPolicy: {
      enabled: softDelete
      days: softDelete ? 7 : null
    }
    containerDeleteRetentionPolicy: {
      enabled: softDelete
      days: softDelete ? 7 : null
    }
  }
}

resource filer 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: sa
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: softDelete
      days: softDelete ? 7 : null
    }
  }
}

output navn string = sa.name
