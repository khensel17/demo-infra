param name string
param location string
// param logAnalyticsCustomerId string

resource managedEnvironment 'Microsoft.App/managedEnvironments@2025-02-02-preview' = {
  name: name
  location: location
  properties: {
    zoneRedundant: false
    kedaConfiguration: {}
    daprConfiguration: {}
    customDomainConfiguration: {}
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
        enableFips: false
      }
    ]
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
    peerTrafficConfiguration: {
      encryption: {
        enabled: false
      }
    }
    publicNetworkAccess: 'Enabled'
  }
}

output managedEnvironmentId string = managedEnvironment.id
output managedEnvironmentName string = managedEnvironment.name


//   name: managedEnvironments_managedEnvironment_rgdemoapp_bbe7_name
//   location: 'West Europe'
//   properties: {
//     appLogsConfiguration: {
//       destination: 'log-analytics'
//       logAnalyticsConfiguration: {
//         customerId: '3f0747e5-f481-4133-8015-762b885e2769'
//         dynamicJsonColumns: false
//       }
//     }
//     zoneRedundant: false
//     kedaConfiguration: {}
//     daprConfiguration: {}
//     customDomainConfiguration: {}
//     workloadProfiles: [
//       {
//         workloadProfileType: 'Consumption'
//         name: 'Consumption'
//         enableFips: false
//       }
//     ]
//     peerAuthentication: {
//       mtls: {
//         enabled: false
//       }
//     }
//     peerTrafficConfiguration: {
//       encryption: {
//         enabled: false
//       }
//     }
//     publicNetworkAccess: 'Enabled'
//   }
// }
