@description('Brukernavnet til administratoren')
param adminUsername string = 'azureuser'

@secure()
@description('Passordet til administratoren. Vi logger ikke inn, så det trengs bare når instansene lages')
param adminPassword string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  name: 'vnet-uke05/default'
}

resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: 'vmss-uke05'
  location: resourceGroup().location
  zones: [ '1', '2', '3' ]
  sku: {
    name: 'Standard_D2als_v6'
    capacity: 2
  }
  properties: {
    orchestrationMode: 'Flexible'
    platformFaultDomainCount: 1
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'vmss'
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
          createOption: 'FromImage'
          deleteOption: 'Delete'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
        }
      }
      networkProfile: {
        networkApiVersion: '2024-05-01'
        networkInterfaceConfigurations: [
          {
            name: 'nic'
            properties: {
              primary: true
              deleteOption: 'Delete'
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    subnet: {
                      id: subnet.id
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
}
