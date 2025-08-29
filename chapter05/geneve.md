# AKS BYOCNI Cluster for Cilium Geneve

This repository provides step-by-step instructions for deploying an [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/) cluster in **Bring-Your-Own-CNI (BYOCNI)** mode.  
The cluster is created without a default CNI plugin so that you can install [Cilium](https://cilium.io) with **Geneve encapsulation**.

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed and authenticated (`az login`)  
- Permissions to create AKS resources in your Azure subscription  

## Deployment Steps

### 1. Create a resource group

The following below creates a resource group in the **canadacentral** region. Feel free to use a different region.

```bash
az group create -l canadacentral -n geneve-rg
```

### 2. Create a virtual network and subnet

Feel free to use different virtual networks and subnets.

```bash
az network vnet create   -g geneve-rg   --location canadacentral   --name geneve-vnet   --address-prefixes 192.168.8.0/22   -o none

az network vnet subnet create   -g geneve-rg   --vnet-name geneve-vnet   --name geneve-subnet   --address-prefixes 192.168.10.0/24   -o none
```

### 3. Capture the subnet ID

```bash
SUBNET_ID=$(az network vnet subnet show   --resource-group geneve-rg   --vnet-name geneve-vnet   --name geneve-subnet   --query id -o tsv)
```

### 4. Create the AKS cluster in BYOCNI mode

```bash
az aks create   -l canadacentral   -g geneve-rg   -n geneve-cluster   --network-plugin none   --vnet-subnet-id "$SUBNET_ID"
```

### 5. Get cluster credentials

```bash
az aks get-credentials --resource-group geneve-rg --name geneve-cluster
```

You can now access your cluster with `kubectl`.

## Cleanup

To avoid incurring charges, delete the resource group when you are finished:

```bash
az group delete --name geneve-rg --yes --no-wait
```
