@description('Størrelsen på VM-ene')
param vmSize string = 'Standard_D2als_v6'

@description('Brukernavnet til administratoren')
param adminUsername string = 'azureuser'

@secure()
@description('Passordet til administratoren. Vi logger ikke inn på VM-ene, så du trenger det ikke')
param adminPassword string = 'Az-${newGuid()}'

@description('VM-ene, subnettene de står i, og de faste IP-ene deres. Webserverne svarer med navnet sitt på port 80')
var vmer = [
  {
    navn: 'vm-web1'
    subnet: 'web'
    ip: '10.8.1.4'
    web: true
  }
  {
    navn: 'vm-web2'
    subnet: 'web'
    ip: '10.8.1.5'
    web: true
  }
  {
    navn: 'vm-klient'
    subnet: 'klient'
    ip: '10.8.2.4'
    web: false
  }
]

@description('Webserveren bruker Python, som allerede finnes i Ubuntu. Subnettene er private, så VM-ene kan ikke laste ned pakker')
var webserver = '''
#cloud-config
write_files:
  - path: /etc/systemd/system/web.service
    content: |
      [Unit]
      Description=Webserver som svarer med navnet til VM-en
      [Service]
      ExecStart=/usr/bin/python3 -m http.server 80 --directory /var/www
      Restart=always
      [Install]
      WantedBy=multi-user.target
runcmd:
  - mkdir -p /var/www
  - hostname > /var/www/index.html
  - systemctl daemon-reload
  - systemctl enable --now web
'''

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-web'
  location: resourceGroup().location
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-uke08'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.8.0.0/16' ]
    }
    subnets: [
      {
        name: 'web'
        properties: {
          addressPrefix: '10.8.1.0/24'
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: 'klient'
        properties: {
          addressPrefix: '10.8.2.0/24'
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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: v.ip
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, v.subnet)
          }
        }
      }
    ]
  }
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
      customData: v.web ? base64(webserver) : null
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

@description('Network Watcher-agenten på vm-klient. Connection troubleshoot og connection monitor trenger den i steg 7 og 8')
resource agent 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vm[2]
  name: 'NetworkWatcherAgentLinux'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentLinux'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
  }
}

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

@description('Log Analytics-workspacen til connection monitoren i steg 8')
resource logg 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-uke08'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}
