ROOT = $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

SCRIPT_FILES = $(shell find . -path ./.git -prune -o -type f -name '*.sh' -print)
YAML_FILES = $(shell find . -path ./.git -prune -o -type f -name '*.yaml' -print)

.PHONY: help
help: ## Show this help
# This awk one-liner from GitHub user @theherk
# link: https://gist.github.com/prwhite/8168133?permalink_comment_id=3624253#gistcomment-3624253
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[$$()% a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: check
check: shellcheck yaml-format ## Check files under the current directory

.PHONY: shellcheck
shellcheck: $(SCRIPT_FILES) ## Run shellcheck on all shell scripts under the current directory
	@shellcheck $^

.PHONY: yaml-format
yaml-format: $(YAML_FILES) ## Check formatting of all YAML files under the current directory
	@"$(ROOT)/util/yamlcheck.sh" $^

