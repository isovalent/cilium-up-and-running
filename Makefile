# Top-level Makefile for "Cilium Up & Running" repo
# Usage examples:
#   make up CHAPTER=ch05-datapath
#   make apply CHAPTER=ch06-services
#   make cilium-install CHAPTER=ch05-datapath CILIUM_VERSION=1.18.2
#   make down

# -------- Variables (override on the command line if needed) --------
CHAPTER           ?= ch05-datapath
CLUSTER           ?= cilium-book
KIND_IMAGE        ?= kindest/node:v1.33.0
CILIUM_VERSION    ?= 1.18.2
KUBECONFIG        ?= $(HOME)/.kube/config
# If a chapter has its own kind.yaml or values.yaml, we prefer those.
CHAPTER_KIND_CFG  := $(CHAPTER)/kind.yaml
COMMON_KIND_CFG   := common/kind.yaml
CHAPTER_VALUES    := $(CHAPTER)/values.yaml
CHAPTER_MANIFESTS := $(CHAPTER)/manifests

# Tools
KIND              ?= kind
KUBECTL           ?= kubectl
HELM              ?= helm

# Internal helper: choose config file if present in chapter, else common
define pick_kind_cfg
@if [ -f "$(CHAPTER_KIND_CFG)" ]; then \
  echo "Using $(CHAPTER_KIND_CFG)"; \
  CFG="$(CHAPTER_KIND_CFG)"; \
elif [ -f "$(COMMON_KIND_CFG)" ]; then \
  echo "Using $(COMMON_KIND_CFG)"; \
  CFG="$(COMMON_KIND_CFG)"; \
else \
  echo "No kind.yaml found in $(CHAPTER) or common/"; \
  exit 1; \
fi; \
$(KIND) create cluster --name "$(CLUSTER)" --image "$(KIND_IMAGE)" --config "$$CFG"
endef

# -------- Phony targets --------
.PHONY: help tools up down reset status kubecontext cilium-repo cilium-install cilium-uninstall \
        apply delete wait logs manifests list-chapters smoke

help:
	@echo "Common targets:"
	@echo "  make up CHAPTER=<folder>            Create kind cluster for a chapter"
	@echo "  make down                           Delete the kind cluster"
	@echo "  make reset CHAPTER=<folder>         Recreate the cluster"
	@echo "  make apply CHAPTER=<folder>         Apply chapter manifests"
	@echo "  make wait                           Wait for nodes and Cilium to be ready"
	@echo "  make cilium-install [CILIUM_VERSION=x.y.z] [CHAPTER=<folder>]"
	@echo "  make cilium-uninstall               Remove Cilium"
	@echo "  make status                         Show cluster info"
	@echo "  make tools                          Check required tools"
	@echo "  make list-chapters                  List chapter folders"
	@echo "  Variables you can override: CLUSTER, KIND_IMAGE, CILIUM_VERSION, KUBECONFIG"

tools:
	@command -v $(KIND) >/dev/null 2>&1 || { echo "Missing: kind"; exit 1; }
	@command -v $(KUBECTL) >/dev/null 2>&1 || { echo "Missing: kubectl"; exit 1; }
	@command -v $(HELM) >/dev/null 2>&1 || { echo "Missing: helm"; exit 1; }
	@echo "All required tools found."

up: tools
	@echo "Creating kind cluster '$(CLUSTER)' with Kubernetes image '$(KIND_IMAGE)'"
	$(call pick_kind_cfg)
	@echo "Cluster created."

down:
	@echo "Deleting kind cluster '$(CLUSTER)'"
	@$(KIND) delete cluster --name "$(CLUSTER)" || true

reset:
	@$(MAKE) down
	@$(MAKE) up CHAPTER="$(CHAPTER)"

status:
	@$(KIND) get clusters
	@$(KUBECTL) cluster-info || true
	@$(KUBECTL) get nodes -o wide || true

kubecontext:
	@echo "Current kubectl context:"
	@KUBECONFIG=$(KUBECONFIG) $(KUBECTL) config current-context || true

cilium-repo:
	@$(HELM) repo add cilium https://helm.cilium.io >/dev/null
	@$(HELM) repo update cilium >/dev/null
	@echo "Helm repo 'cilium' ready."

cilium-install: cilium-repo
	@echo "Installing Cilium $(CILIUM_VERSION) into cluster '$(CLUSTER)'"
	@if [ -f "$(CHAPTER_VALUES)" ]; then \
	  echo "Using chapter values: $(CHAPTER_VALUES)"; \
	  $(HELM) upgrade --install cilium cilium/cilium \
	    --version "$(CILIUM_VERSION)" \
	    --namespace kube-system \
	    -f "$(CHAPTER_VALUES)"; \
	else \
	  echo "No chapter values.yaml; using defaults"; \
	  $(HELM) upgrade --install cilium cilium/cilium \
	    --version "$(CILIUM_VERSION)" \
	    --namespace kube-system \
	    --set kubeProxyReplacement=true \
	    --set k8sServiceHost=$$($(KUBECTL) get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}') \
	    --set k8sServicePort=6443; \
	fi
	@echo "Cilium install invoked."

cilium-uninstall:
	@$(HELM) uninstall cilium -n kube-system || true
	@echo "Cilium uninstalled."

apply:
	@if [ -d "$(CHAPTER_MANIFESTS)" ]; then \
	  echo "Applying manifests in $(CHAPTER_MANIFESTS)"; \
	  $(KUBECTL) apply -f "$(CHAPTER_MANIFESTS)"; \
	else \
	  echo "No manifests directory found at $(CHAPTER_MANIFESTS)"; \
	fi

delete:
	@if [ -d "$(CHAPTER_MANIFESTS)" ]; then \
	  echo "Deleting manifests in $(CHAPTER_MANIFESTS)"; \
	  $(KUBECTL) delete -f "$(CHAPTER_MANIFESTS)" --ignore-not-found; \
	else \
	  echo "No manifests directory found at $(CHAPTER_MANIFESTS)"; \
	fi

wait:
	@echo "Waiting for nodes to be Ready..."
	@$(KUBECTL) wait --for=condition=Ready nodes --all --timeout=180s
	@echo "Waiting for Cilium pods in kube-system..."
	@$(KUBECTL) -n kube-system rollout status ds/cilium --timeout=180s || true
	@$(KUBECTL) -n kube-system rollout status deploy/cilium-operator --timeout=180s || true

logs:
	@$(KUBECTL) -n kube-system logs ds/cilium --tail=200 || true
	@$(KUBECTL) -n kube-system logs deploy/cilium-operator --tail=200 || true

manifests:
	@echo "Scaffolding chapter manifests directory if missing."
	@mkdir -p "$(CHAPTER_MANIFESTS)"
	@touch "$(CHAPTER_MANIFESTS)/.keep"
	@echo "Done: $(CHAPTER_MANIFESTS)"

list-chapters:
	@find . -maxdepth 1 -type d -name "ch*" | sort | sed 's|^\./||'

smoke:
	@echo "kubectl version (client):"
	@$(KUBECTL) version --client --output=yaml || true
	@echo "helm version:"
	@$(HELM) version || true
	@echo "kind version:"
	@$(KIND) version || true
