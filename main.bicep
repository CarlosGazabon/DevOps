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
param webAppNameSettings string
param existingRG string


//Variables para obtener lista de los app setttings
var currentAppSettingsApi = list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebApp.name, 'appsettings'), '2023-12-01').properties

//Variables para obtener los connection strings
var currentConnecStringsApi = list(resourceId(az.subscription().subscriptionId,existingRG,'Microsoft.Web/sites/config', existingWebApp.name, 'connectionstrings'), '2023-12-01').properties

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
    cliente: cliente //Ingresa el nombre del plan de la ap
    currentAppSettings: currentAppSettingsApi
    additionalAppSettingsApi: union({
      'URLs:API': 'https://webapp-${cliente}-${env}.azurewebsites.net'
      'URLs:FrontURL': env == 'pro' ? 'https://webapp-${cliente}.azurewebsites.net.com' : 'https://webapp-${cliente}-${env}.azurewebsites.net'
      'Tenant:Id': toUpper(cliente)
      'Tenant:Environment': toUpper(env)
    }, env == 'pro' ? {
      APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.outputs.instrumentationKey
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.outputs.instrumentationKey
    } : {})
    
    currentConnecStringsApi: currentConnecStringsApi
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
    name: 'acr-${cliente}-${env}'
    location: location
    sku: 'Standard'
    adminUserEnabled: true
  }
}

resource existingWebApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppNameSettings
  scope: resourceGroup(existingRG)
}
