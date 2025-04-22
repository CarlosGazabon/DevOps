param name string
param location string = resourceGroup().location
param sku string = 'Basic' // Opciones: Basic, Standard, Premium
param adminUserEnabled bool = false

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}

output acrLoginServer string = acr.properties.loginServer
output acrName string = acr.name
