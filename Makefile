# Top-level Makefile for "Cilium Up & Running" repo
# Usage examples:
#   make up chapter03
#   make apply chapter03 USE_CASE=basic-policies
#   make cilium-install chapter03 CILIUM_VERSION=1.18.2
#   make down

# -------- Variables (override on the command line if needed) --------
CLUSTER           ?= cilium-book
KIND_IMAGE        ?= kindest/node:v1.33.0
CILIUM_VERSION    ?= 1.18.2
USE_CASE          ?= # Optional use case within chapter
KUBECONFIG        ?= $(HOME)/.kube/config

# Parse arguments to extract chapter (first non-target argument)
CHAPTER := $(filter chapter%, $(MAKECMDGOALS))

# Default chapter if none provided
ifeq ($(CHAPTER),)
CHAPTER := ch05-datapath
endif

# If a chapter has its own kind.yaml or values.yaml, we prefer those.
CHAPTER_KIND_CFG  := $(CHAPTER)/kind.yaml
COMMON_KIND_CFG   := common/kind.yaml
CHAPTER_VALUES    := $(CHAPTER)/values.yaml
# Support for use-case specific configs and manifests
USE_CASE_KIND     := $(if $(USE_CASE),$(CHAPTER)/$(USE_CASE)/kind.yaml,$(CHAPTER_KIND_CFG))
USE_CASE_VALUES   := $(if $(USE_CASE),$(CHAPTER)/$(USE_CASE)/values.yaml,$(CHAPTER_VALUES))
MANIFESTS_DIR     := $(if $(USE_CASE),$(CHAPTER)/$(USE_CASE)/manifests,$(CHAPTER)/manifests)

# Tools
KIND              ?= kind
KUBECTL           ?= kubectl
HELM              ?= helm

# Internal helper: choose config file if present in use-case, chapter, or common
define pick_kind_cfg
@if [ -f "$(USE_CASE_KIND)" ]; then \
  echo "Using $(USE_CASE_KIND)"; \
  CFG="$(USE_CASE_KIND)"; \
elif [ -f "$(CHAPTER_KIND_CFG)" ]; then \
  echo "Using $(CHAPTER_KIND_CFG)"; \
  CFG="$(CHAPTER_KIND_CFG)"; \
elif [ -f "$(COMMON_KIND_CFG)" ]; then \
  echo "Using $(COMMON_KIND_CFG)"; \
  CFG="$(COMMON_KIND_CFG)"; \
else \
  echo "No kind.yaml found in $(USE_CASE), $(CHAPTER) or common/"; \
  exit 1; \
fi; \
$(KIND) create cluster --name "$(CLUSTER)" --image "$(KIND_IMAGE)" --config "$$CFG"
endef

# -------- Phony targets --------
.PHONY: help tools up down reset status kubecontext cilium-repo cilium-install cilium-uninstall \
        apply delete wait logs manifests list-chapters smoke

# Handle arguments as empty targets to prevent "No rule to make target" errors
chapter%:
	@:

%:
	@:

help:
	@echo "Common targets:"
	@echo "  make up <chapter> [USE_CASE=<use-case>]             Create kind cluster"
	@echo "  make down                                           Delete the kind cluster"
	@echo "  make reset <chapter> [USE_CASE=<use-case>]         Recreate the cluster"
	@echo "  make apply <chapter> [USE_CASE=<use-case>]         Apply manifests"
	@echo "  make wait                                           Wait for readiness"
	@echo "  make cilium-install <chapter> [CILIUM_VERSION=x.y.z] [USE_CASE=<use-case>]"
	@echo "  make cilium-uninstall                               Remove Cilium"
	@echo "  make status                                         Show cluster info"
	@echo "  make tools                                          Check required tools"
	@echo "  make list-chapters                                  List chapter folders"
	@echo "  Variables: CLUSTER, KIND_IMAGE, KUBECONFIG"
	@echo ""
	@echo "Examples:"
	@echo "  make up chapter03 USE_CASE=basic-policies"
	@echo "  make apply chapter03 USE_CASE=l7-policies"
	@echo "  make cilium-install chapter06 CILIUM_VERSION=1.18.1"

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
	@$(MAKE) up $(CHAPTER) $(if $(USE_CASE),USE_CASE=$(USE_CASE))

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

cilium-install:
	@echo "Installing Cilium $(CILIUM_VERSION) into cluster '$(CLUSTER)'"
	@if [ -f "$(USE_CASE_VALUES)" ]; then \
	  echo "Using values: $(USE_CASE_VALUES)"; \
	  $(HELM) upgrade --install cilium cilium/cilium \
	    --version "$(CILIUM_VERSION)" \
	    --namespace kube-system \
	    -f "$(USE_CASE_VALUES)"; \
	else \
	  echo "No values.yaml found; using Cilium CLI with defaults"; \
	  cilium install --version "$(CILIUM_VERSION)"; \
	fi
	@echo "Cilium install invoked."

cilium-uninstall:
	@$(HELM) uninstall cilium -n kube-system || true
	@echo "Cilium uninstalled."

apply:
	@echo "Applying YAML manifests from $(MANIFESTS_DIR)/"
	@if [ -d "$(MANIFESTS_DIR)" ]; then \
	  if ls $(MANIFESTS_DIR)/*.yaml >/dev/null 2>&1; then \
	    for file in $(MANIFESTS_DIR)/*.yaml; do \
	      echo "Applying $$file"; \
	      $(KUBECTL) apply -f "$$file"; \
	    done; \
	  fi; \
	  if ls $(MANIFESTS_DIR)/*.yml >/dev/null 2>&1; then \
	    for file in $(MANIFESTS_DIR)/*.yml; do \
	      echo "Applying $$file"; \
	      $(KUBECTL) apply -f "$$file"; \
	    done; \
	  fi; \
	else \
	  echo "No manifests directory found at $(MANIFESTS_DIR)"; \
	fi

delete:
	@echo "Deleting YAML manifests from $(MANIFESTS_DIR)/"
	@if [ -d "$(MANIFESTS_DIR)" ]; then \
	  if ls $(MANIFESTS_DIR)/*.yaml >/dev/null 2>&1; then \
	    for file in $(MANIFESTS_DIR)/*.yaml; do \
	      echo "Deleting $$file"; \
	      $(KUBECTL) delete -f "$$file" --ignore-not-found; \
	    done; \
	  fi; \
	  if ls $(MANIFESTS_DIR)/*.yml >/dev/null 2>&1; then \
	    for file in $(MANIFESTS_DIR)/*.yml; do \
	      echo "Deleting $$file"; \
	      $(KUBECTL) delete -f "$$file" --ignore-not-found; \
	    done; \
	  fi; \
	else \
	  echo "No manifests directory found at $(MANIFESTS_DIR)"; \
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
	@echo "Manifests directory: $(MANIFESTS_DIR)"
	@echo "Available manifests:"
	@if [ -d "$(MANIFESTS_DIR)" ]; then \
	  ls -la $(MANIFESTS_DIR)/*.yaml $(MANIFESTS_DIR)/*.yml 2>/dev/null || echo "No YAML files found"; \
	else \
	  echo "Directory $(MANIFESTS_DIR) does not exist"; \
	fi

list-chapters:
	@find . -maxdepth 1 -type d -name "ch*" | sort | sed 's|^\./||'

smoke:
	@echo "kubectl version (client):"
	@$(KUBECTL) version --client --output=yaml || true
	@echo "helm version:"
	@$(HELM) version || true
	@echo "kind version:"
	@$(KIND) version || true
