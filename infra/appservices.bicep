param location string= resourceGroup().location
param cliente string
param appServiceLinuxVersion string
param env string

param appServicePlanNameApi string
var appServiceApiName= 'webapp-${cliente}-${env}'


//App settings nuevos
param additionalAppSettingsApi object = {}

//Connection String existentes
param currentConnecStringsApi object = {}

/* ------------SETEO DE CONECTION STRINGS------------------------- */
var additionalConnStringsApi = {
  DefaultConnection: {
    value: env == 'pro' 
      ? 'Server=tcp:server-production${environment().suffixes.sqlServerHostname},1433;Initial Catalog=databasename;Persist Security Info=False;User ID=inventio;Password=passwordeprueba;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
      : 'Server=tcp:server-demo${environment().suffixes.sqlServerHostname},1433;Initial Catalog=databasename;Persist Security Info=False;User ID=inventio;Password=passwordeprueba;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
    type: 'SQLServer'
  }
}


/* ------------CREACIÓN DE APP SERVICE PLAN LINUX------------------------- */
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanNameApi
  location: location
  sku: {
    name: 'B1'
  }
  properties: {
    reserved: true

  }
  kind: 'linux'
}


/* ------------CREACIÓN DE APP SERVICE TIPO LINUX------------------------- */
resource appServiceApp 'Microsoft.Web/sites@2023-01-01' = {
  name: appServiceApiName
  location: location
  tags: {
    TENANT: toUpper(cliente)
  }
  properties:{
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    
    siteConfig: {
      linuxFxVersion:appServiceLinuxVersion
      use32BitWorkerProcess: true
      ftpsState: 'Disabled'
      alwaysOn: false
      appSettings: []

      connectionStrings: []
    }
    }
}

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceApp
  name: 'appsettings'
  properties: additionalAppSettingsApi
}


resource siteconfig5 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: appServiceApp
  name: 'connectionstrings'
  properties: union(currentConnecStringsApi, additionalConnStringsApi)
}


output planNameapp string = appServicePlan.name


