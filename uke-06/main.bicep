@description('Navnet på web-appen. Må være unikt i hele Azure')
param appName string

@description('Tieren til App Service-planen. Slots og autoscale krever Standard eller høyere')
param sku string = 'S1'

resource plan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'plan-uke06'
  location: resourceGroup().location
  kind: 'linux'
  sku: {
    name: sku
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource app 'Microsoft.Web/sites@2024-04-01' = {
  name: appName
  location: resourceGroup().location
  kind: 'app,linux'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'PHP|8.4'
    }
  }
}

output url string = 'https://${app.properties.defaultHostName}'
