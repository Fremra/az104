@description('Størrelsen på VM-ene')
param vmSize string = 'Standard_D2als_v6'

@description('Brukernavnet til administratoren')
param adminUsername string = 'azureuser'

@secure()
@description('Passordet til administratoren. Du trenger det til Bastion i steg 7')
param adminPassword string

@description('VM-ene og subnettene de står i')
var vmer = [
  {
    navn: 'vm-web'
    vnet: 'vnet-app'
    subnet: 'web'
  }
  {
    navn: 'vm-db'
    vnet: 'vnet-app'
    subnet: 'db'
  }
  {
    navn: 'vm-nva'
    vnet: 'vnet-hub'
    subnet: 'nva'
  }
]

resource app 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-app'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.7.0.0/16' ]
    }
    subnets: [
      {
        name: 'web'
        properties: {
          addressPrefix: '10.7.1.0/24'
          defaultOutboundAccess: false
        }
      }
      {
        name: 'db'
        properties: {
          addressPrefix: '10.7.2.0/24'
          defaultOutboundAccess: false
        }
      }
    ]
  }
}

resource hub 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-hub'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.70.0.0/16' ]
    }
    subnets: [
      {
        name: 'nva'
        properties: {
          addressPrefix: '10.70.1.0/24'
          defaultOutboundAccess: false
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = [for v in vmer: {
  name: '${v.navn}-nic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', v.vnet, v.subnet)
          }
        }
      }
    ]
  }
  dependsOn: [
    app
    hub
  ]
}]

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = [for (v, i) in vmer: {
  name: v.navn
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: v.navn
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        name: '${v.navn}-osdisk'
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
  }
}]

resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = [for (v, i) in vmer: {
  name: 'shutdown-computevm-${v.navn}'
  location: resourceGroup().location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '2000'
    }
    timeZoneId: 'W. Europe Standard Time'
    targetResourceId: vm[i].id
    notificationSettings: {
      status: 'Disabled'
    }
  }
}]
