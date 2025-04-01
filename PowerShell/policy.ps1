# Definiujemy zmienne
$policyName = "ApplyDSCPolicy"
$policyDisplayName = "Apply DSC Configuration from Azure Storage"
$storageAccountName = "githubrepobackupstorage"
$containerName = "dscconfigs"
$blobName = "InstallNginx.mof"
$resourceGroup = "monitoring-RG-Linux"
$subscriptionId = "275da9d4-fda5-4693-aa9d-f77ed05f7ef3"

# Tworzymy definicję polisy
$policyDefinition = @{
    "properties" = @{
        "displayName" = $policyDisplayName
        "policyType"  = "Custom"
        "mode"        = "All"
        "metadata"    = @{ "category" = "DSC" }
        "parameters"  = @{}
        "policyRule"  = @{
            "if" = @{
                "field" = "type"
                "equals" = "Microsoft.HybridCompute/machines"
            }
            "then" = @{
                "effect" = "deployIfNotExists"
                "details" = @{
                    "type" = "Microsoft.Automanage/configurationProfileAssignments"
                    "name" = "[concat(parameters('machineName'), '-DSC-Profile')]"
                    "existenceCondition" = @{
                        "field" = "Microsoft.Automanage/configurationProfileAssignments/configurationProfile"
                        "equals" = "[concat('https://', '$storageAccountName', '.blob.core.windows.net/', '$containerName', '/', '$blobName')]"
                    }
                    "deployment" = @{
                        "properties" = @{
                            "mode" = "Incremental"
                            "template" = @{
                                "$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
                                "contentVersion" = "1.0.0.0"
                                "resources" = @(
                                    @{
                                        "type" = "Microsoft.Automanage/configurationProfileAssignments"
                                        "apiVersion" = "2021-04-30-preview"
                                        "name" = "[concat(parameters('machineName'), '-DSC-Profile')]"
                                        "properties" = @{
                                            "configurationProfile" = "[concat('https://', '$storageAccountName', '.blob.core.windows.net/', '$containerName', '/', '$blobName')]"
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

# Utworzenie polisy w Azure
$policyDefinitionJson = $policyDefinition | ConvertTo-Json -Depth 10
$policyDefPath = "./dscPolicyDefinition.json"
$policyDefinitionJson | Out-File -Encoding utf8 $policyDefPath

New-AzPolicyDefinition -Name $policyName -Policy $policyDefPath -Mode All -SubscriptionId $subscriptionId

# Przypisanie polisy do Resource Group
New-AzPolicyAssignment -Name $policyName -PolicyDefinitionName $policyName -Scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup"
