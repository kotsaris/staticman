$ErrorActionPreference = "Stop"
#Needs kotsaris toolbelt loaded into profile.
Set-KeyVaultSecretsAsEnvironmentVariables konsecrets
az account set --subscription $env:subscriptionId
#Environment Variables you can setup:
#https://staticman.net/docs/api
# $jsonFilePath = "config.production.json"
# $secrets = @{
#     "githubAppID"= "$($env:staticmanGithubAppId)"
#     "githubToken"= "$($env:staticmanGithubToken)"
#     "rsaPrivateKey"= "$($env:staticmanRsaPrivateKey)"
#     "githubPrivateKey"= "$($env:staticmanGithubPrivateKey)"
#     "port"= 80
#     "env"= "production"
#   }
# $jsonString = $secrets | ConvertTo-Json -Depth 10
# $jsonString = $jsonString.Replace("\\n", "\n")
# $jsonString | Set-Content -Path $jsonFilePath

# #Create the image
# az acr login --name $env:acrName

# docker-compose -f docker-compose.yml build
# docker-compose -f docker-compose.yml push

#Deploy it to a webapp
$appName = "codesenninstatics"
Write-Host "Deleting the webapp if it exists"
az webapp delete --name $appName --resource-group $env:resourceGroup
Write-Host "Deleting the app service plan if it exists"
az appservice plan delete --name $env:linuxAppServicePlan --resource-group $env:resourceGroup --yes

Write-Host "Creating the app service plan"
az appservice plan create --name $env:linuxAppServicePlan `
    --resource-group $env:resourceGroup `
    --sku B1 `
    --is-linux `
    --location westeurope

Write-Host "Creating the webapp"
az webapp create --resource-group $env:resourceGroup `
    --plan $env:linuxAppServicePlan `
    --name $appName `
    --deployment-container-image-name "$($env:acrName)/staticman:latest" `

Write-Host "Setting the environment variables"
az webapp config appsettings set --resource-group $env:resourceGroup `
    --name $appName `
    --settings APPINSIGHTS_INSTRUMENTATIONKEY=$env:appInsightsInstrumentationKey

Write-Host "Setting the always on"
az webapp config set --resource-group $env:resourceGroup `
--name $appName `
--always-on true