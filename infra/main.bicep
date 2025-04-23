// Nombre del archivo: main.bicep
//Parametros globales para todos los modulos
param env string
param cliente string
param location string= 'eastus2'

//Parametros de Storage
param storageAccesTier string = 'Hot' //Opciones: 'Hot', 'Cool', 'Archive'
param StorageSku string = 'Standard_LRS' //Opciones: 'Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_ZRS', 'Premium_LRS', 'Premium_GRS', 'Premium_RAGRS', 'Premium_ZRS'

//Parametros de Resource Group
var rgName = '${toUpper('rg')}-${toUpper(cliente)}-${toUpper(env)}'


//Parametros de App Service Plan y AppService
param appServicePlanNameApi string
param appServiceLinuxVersion string


targetScope = 'subscription'

resource newResourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: rgName
  location: location
}

module AppServices 'appservices.bicep' ={
  name: 'AppService'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    location: location
    //*IMPORTANTE* TODA INFORMACION INGRESADA DEBE SER DENTRO LAS COMILLAS ''
    env: env //Opciones: 'qa', 'beta', 'pro'
    appServiceLinuxVersion: appServiceLinuxVersion //*RELLENAR SOLO SI ES LINUX SI NO DEJAR VACIA LAS COMILLAS* Ingrese la version de su API LINUX: 'DOTNETCORE|6.0', 'ASPNET|V4.8'
    cliente: cliente 
    additionalAppSettingsApi: {
      URLs__API: 'https://webapp-${cliente}-${env}.azurewebsites.net'
      URLs_FrontURL: env == 'pro' ? 'https://webapp-${cliente}.azurewebsites.net.com' : 'https://webapp-${cliente}-${env}.azurewebsites.net'
      Tenant_Id: toUpper(cliente)
      Tenant_Environment: toUpper(env)
      APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.outputs.instrumentationKey
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.outputs.instrumentationKey
      DOCKER_REGISTRY_SERVER_URL: acrModule.outputs.acrLoginServer
      DOCKER_REGISTRY_SERVER_USERNAME: acrModule.outputs.acrName

    }
    appServicePlanNameApi: appServicePlanNameApi
    }
  }

module appInsights 'appinsights.bicep' = {
  name: 'AppInsights'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    location: location
    env: env
    cliente: cliente
  }
}


module storage 'storages.bicep'={
  name: 'functionAppStorage'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    env: env //Opciones: 'qa', 'beta', 'pro'
    cliente: cliente
    location: location
    storageAccesTier: storageAccesTier //Ingresa el accessTier del storage
    StorageSku: StorageSku //Ingresa el Sku del storage (Produccion se usa: 'Standard_LRS')
  }
}

module acrModule 'acr.bicep' = {
  name: 'deployAcr'
  scope: resourceGroup(newResourceGroup.name)
  params: {
    name: 'acr${cliente}${env}'
    location: location
    sku: 'Standard'
    adminUserEnabled: true
  }
}
