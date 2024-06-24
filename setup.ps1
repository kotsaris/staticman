$ErrorActionPreference = "Stop"
#Needs kotsaris toolbelt loaded into profile.
Set-KeyVaultSecretsAsEnvironmentVariables konsecrets
az account set --subscription $env:subscriptionId
#Environment Variables you can setup:
#https://staticman.net/docs/api
$jsonFilePath = "config.production.json"
$secrets = @{
    "githubAppID"= "$($env:staticmanGithubAppId)"
    "githubToken"= "$($env:staticmanGithubToken)"
    "rsaPrivateKey"= "$($env:staticmanRsaPrivateKey)"
    "githubPrivateKey"= "$($env:staticmanGithubPrivateKey)"
    "port"= 80
    "env"= "production"
  }
$jsonString = $secrets | ConvertTo-Json -Depth 10
$jsonString = $jsonString.Replace("\\n", "\n")
$jsonString | Set-Content -Path $jsonFilePath
$appName = "codesenninstatics"

#Create the image
az acr login --name $env:acrName

docker-compose -f docker-compose.yml build
docker-compose -f docker-compose.yml push

#Deploy it to a webapp
az webapp delete --name $appName --resource-group $env:resourceGroup --yes
az appservice plan delete --name $env:staticmanAppServicePlan --resource-group $env:resourceGroup --yes

az appservice plan create --name $env:staticmanAppServicePlan --resource-group $env:resourceGroup --sku B1 --is-linux
az webapp create --resource-group $env:resourceGroup `
    --plan $env:staticmanAppServicePlan `
    --name $appName `
    --deployment-container-image-name "$($env:acrName)/staticman:latest"

az webapp config appsettings set --resource-group $env:resourceGroup `
    --name $appName `
    --settings APPINSIGHTS_INSTRUMENTATIONKEY=$env:appInsightsInstrumentationKey
