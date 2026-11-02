@description('DNS-navnet til container groupen. Må være unikt i regionen')
param dnsLabel string

@allowed([ 'Always', 'OnFailure', 'Never' ])
@description('Hva Azure gjør når en container stopper')
param restartPolicy string = 'OnFailure'

resource gruppe 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'aci-gruppe'
  location: resourceGroup().location
  properties: {
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: {
      type: 'Public'
      dnsNameLabel: dnsLabel
      ports: [
        {
          port: 80
          protocol: 'TCP'
        }
      ]
    }
    containers: [
      {
        name: 'web'
        properties: {
          image: 'mcr.microsoft.com/azuredocs/aci-helloworld:latest'
          ports: [
            {
              port: 80
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
      {
        name: 'sidecar'
        properties: {
          image: 'mcr.microsoft.com/azurelinux/busybox:1.36'
          command: [
            'sh'
            '-c'
            'while true; do wget -q -O - http://localhost:80 | grep -o "Welcome to Azure Container Instances"; sleep 30; done'
          ]
          resources: {
            requests: {
              cpu: json('0.5')
              memoryInGB: json('0.5')
            }
          }
        }
      }
    ]
  }
}

output fqdn string = gruppe.properties.ipAddress.fqdn
