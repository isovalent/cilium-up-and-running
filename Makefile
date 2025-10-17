# Top-level Makefile for "Cilium Up & Running" repo
# Usage examples:
#   make up chapter03
#   make apply chapter03 USE_CASE=basic-policies
#   make cilium-install chapter03 CILIUM_VERSION=1.18.2
#   make down

# -------- Variables (override on the command line if needed) --------
CLUSTER           ?= kind
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

# Smart values resolution for chapters with common/ directory
define resolve_values
$(shell \
  if [ -f "$(USE_CASE_VALUES)" ]; then \
    echo "$(USE_CASE_VALUES)"; \
  elif [ -f "$(CHAPTER_VALUES)" ]; then \
    echo "$(CHAPTER_VALUES)"; \
  elif [ -f "$(CHAPTER)/common/cilium-gatewayapi-values.yaml" ] && echo "$(USE_CASE)" | grep -E "gateway|grpc|gamma" >/dev/null; then \
    echo "$(CHAPTER)/common/cilium-gatewayapi-values.yaml"; \
  elif [ -f "$(CHAPTER)/common/cilium-ingress-values.yaml" ] && echo "$(USE_CASE)" | grep "ingress" >/dev/null; then \
    echo "$(CHAPTER)/common/cilium-ingress-values.yaml"; \
  elif [ -f "$(CHAPTER)/common/cilium-gatewayapi-values.yaml" ]; then \
    echo "$(CHAPTER)/common/cilium-gatewayapi-values.yaml"; \
  else \
    echo ""; \
  fi \
)
endef

RESOLVED_VALUES := $(resolve_values)

# Tools
KIND              ?= kind
KUBECTL           ?= kubectl
HELM              ?= helm
CILIUM            ?= cilium

# Internal helper: choose config file if present in use-case, chapter, or common
define pick_kind_cfg
@if $(KIND) get clusters | grep -q "^$(CLUSTER)$$"; then \
  echo "Cluster '$(CLUSTER)' already exists. Use 'make down' to delete it first, or 'make reset' to recreate."; \
  exit 1; \
fi; \
if [ -f "$(USE_CASE_KIND)" ]; then \
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
        apply delete wait logs manifests debug-values list-chapters list-use-cases smoke

# Handle arguments as empty targets to prevent "No rule to make target" errors
chapter%:
	@:

%:
	@:

help:
	@echo "Common targets:"
	@echo "  make up <chapter> [USE_CASE=<use-case>]             Create kind cluster (fails if exists)"
	@echo "  make down                                           Delete the kind cluster"
	@echo "  make reset <chapter> [USE_CASE=<use-case>]         Recreate the cluster (delete + create)"
	@echo "  make apply <chapter> [USE_CASE=<use-case>]         Apply manifests"
	@echo "  make wait                                           Wait for readiness"
	@echo "  make cilium-install <chapter> [CILIUM_VERSION=x.y.z] [USE_CASE=<use-case>]"
	@echo "  make cilium-uninstall                               Remove Cilium"
	@echo "  make status                                         Show cluster info"
	@echo "  make debug-values <chapter> [USE_CASE=<use-case>]  Show which values file would be used"
	@echo "  make tools                                          Check required tools"
	@echo "  make list-chapters                                  List chapter folders"
	@echo "  make list-use-cases [<chapter>]                    List all use cases (or for specific chapter)"
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
	@command -v $(CILIUM) >/dev/null 2>&1 || { echo "Missing: cilium CLI"; exit 1; }
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
	@echo "=== Kind Clusters ==="
	@$(KIND) get clusters || echo "No kind clusters found"
	@echo ""
	@echo "=== Cluster Info ==="
	@$(KUBECTL) cluster-info || true
	@echo ""
	@echo "=== Nodes ==="
	@$(KUBECTL) get nodes -o wide || true
	@echo ""
	@echo "=== Cilium Status ==="
	@$(CILIUM) status || true

kubecontext:
	@echo "Current kubectl context:"
	@KUBECONFIG=$(KUBECONFIG) $(KUBECTL) config current-context || true

cilium-repo:
	@$(HELM) repo add cilium https://helm.cilium.io >/dev/null
	@$(HELM) repo update cilium >/dev/null
	@echo "Helm repo 'cilium' ready."

cilium-install:
	@echo "Installing Cilium $(CILIUM_VERSION) into cluster '$(CLUSTER)'"
	@RESOLVED_VALUES="$(RESOLVED_VALUES)"; \
	if [ -n "$$RESOLVED_VALUES" ]; then \
	  echo "Using values: $$RESOLVED_VALUES"; \
	  $(HELM) upgrade --install cilium cilium/cilium \
	    --version "$(CILIUM_VERSION)" \
	    --namespace kube-system \
	    -f "$$RESOLVED_VALUES"; \
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
	@echo "Waiting for Cilium to be ready..."
	@$(CILIUM) status --wait || { \
		echo "Cilium status --wait failed, falling back to kubectl checks..."; \
		$(KUBECTL) -n kube-system rollout status ds/cilium --timeout=180s || true; \
		$(KUBECTL) -n kube-system rollout status deploy/cilium-operator --timeout=180s || true; \
	}

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

debug-values:
	@echo "=== Values Resolution Debug ==="
	@echo "Chapter: $(CHAPTER)"
	@echo "Use Case: $(USE_CASE)"
	@echo "USE_CASE_VALUES: $(USE_CASE_VALUES)"
	@echo "CHAPTER_VALUES: $(CHAPTER_VALUES)"
	@echo "RESOLVED_VALUES: $(RESOLVED_VALUES)"
	@echo ""
	@RESOLVED_VALUES="$(RESOLVED_VALUES)"; \
	if [ -n "$$RESOLVED_VALUES" ]; then \
	  echo "Would use: $$RESOLVED_VALUES"; \
	  if [ -f "$$RESOLVED_VALUES" ]; then \
	    echo "✅ File exists"; \
	  else \
	    echo "❌ File does not exist"; \
	  fi; \
	else \
	  echo "Would use: Cilium CLI defaults (no values file)"; \
	fi

list-chapters:
	@find . -maxdepth 1 -type d -name "ch*" | sort | sed 's|^\./||'

list-use-cases:
	@if [ -n "$(CHAPTER)" ] && [ "$(CHAPTER)" != "ch05-datapath" ]; then \
	  echo "=== Use cases for $(CHAPTER) ==="; \
	  if [ -d "$(CHAPTER)" ]; then \
	    find "$(CHAPTER)" -mindepth 1 -maxdepth 2 -type d ! -name "common" ! -name "manifests" | \
	    sed 's|$(CHAPTER)/||' | sort; \
	  else \
	    echo "Chapter $(CHAPTER) does not exist"; \
	  fi; \
	else \
	  echo "=== All Use Cases by Chapter ==="; \
	  for chapter in $$(find . -maxdepth 1 -type d -name "ch*" | sort | sed 's|^\./||'); do \
	    echo ""; \
	    echo "$$chapter:"; \
	    if [ -d "$$chapter" ]; then \
	      find "$$chapter" -mindepth 1 -maxdepth 2 -type d ! -name "common" ! -name "manifests" | \
	      sed "s|$$chapter/||" | sed 's|^|  |' | sort; \
	    fi; \
	  done; \
	fi

smoke:
	@echo "kubectl version (client):"
	@$(KUBECTL) version --client --output=yaml || true
	@echo "helm version:"
	@$(HELM) version || true
	@echo "kind version:"
	@$(KIND) version || true
