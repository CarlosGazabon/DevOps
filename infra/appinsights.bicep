param location string
param env string
param cliente string

var appInsightsName = 'webapp-${cliente}-${env}'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
  tags: {
    TENANT: toUpper(cliente)
  }
}

output instrumentationKey string = appInsights.properties.ConnectionString
