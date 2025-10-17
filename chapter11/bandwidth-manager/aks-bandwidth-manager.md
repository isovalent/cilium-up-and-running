# AKS BYOCNI Cluster for Cilium Bandwidth Manager

This repository provides step-by-step instructions for deploying an [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/) cluster in **Bring-Your-Own-CNI (BYOCNI)** mode.  
The cluster is created without a default CNI plugin so that you can install [Cilium](https://cilium.io) with the **Bandwidth Manager** feature enabled.

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed and authenticated (`az login`)  
- Permissions to create AKS resources in your Azure subscription  

## Deployment Steps

### 1. Create a resource group

The command below creates a resource group in the **canadacentral** region. Feel free to use a different region.

```bash
az group create -l canadacentral -n bandwidth-rg
```

### 2. Create a virtual network and subnet

You can adjust the address space as needed for your environment.

```bash
az network vnet create \
  -g bandwidth-rg \
  --location canadacentral \
  --name bandwidth-vnet \
  --address-prefixes 192.168.8.0/22 \
  -o none

az network vnet subnet create \
  -g bandwidth-rg \
  --vnet-name bandwidth-vnet \
  --name bandwidth-subnet \
  --address-prefixes 192.168.10.0/24 \
  -o none
```

### 3. Capture the subnet ID

```bash
SUBNET_ID=$(az network vnet subnet show \
  --resource-group bandwidth-rg \
  --vnet-name bandwidth-vnet \
  --name bandwidth-subnet \
  --query id -o tsv)
```

### 4. Create the AKS cluster in BYOCNI mode

```bash
az aks create \
  -l canadacentral \
  -g bandwidth-rg \
  -n bandwidth-cluster \
  --network-plugin none \
  --vnet-subnet-id "$SUBNET_ID"
```

### 5. Get cluster credentials

```bash
az aks get-credentials --resource-group bandwidth-rg --name bandwidth-cluster
```

You can now access your cluster with `kubectl` and install Cilium with Bandwidth Manager enabled. For example:

```bash
helm install cilium cilium/cilium --version <VERSION> \
  --namespace kube-system \
  --set bandwidthManager.enabled=true
```

## Cleanup

To avoid incurring charges, delete the resource group when you are finished:

```bash
az group delete --name bandwidth-rg --yes --no-wait
```
