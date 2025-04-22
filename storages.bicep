param location string= resourceGroup().location
param storageAccesTier string = 'Hot'
param StorageSku string
param cliente string
param env string



var Storagename= 'webapp-${cliente}-${env}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' ={
  name: Storagename
  location: location
  sku: {
    name: StorageSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: storageAccesTier
    minimumTlsVersion: 'TLS1_2'
  }

}

