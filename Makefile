IMAGE ?= ghcr.io/samhclark/agent-sandbox
TAG   ?= latest

.DEFAULT_GOAL := help

##@ Utility

help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

deps: ## Install/verify build dependencies
	@command -v podman >/dev/null 2>&1 || { echo "podman is required but not installed"; exit 1; }
	@echo "All dependencies present."

check: ## Lint the Containerfile and workflows (stub)
	@echo "No checks wired up yet."

test: ## Run tests against the built image (stub)
	@echo "No tests wired up yet."

##@ Building

build: ## Build the container image locally
	podman build -t $(IMAGE):$(TAG) -f Containerfile .

clean: ## Remove the locally built image
	-podman rmi $(IMAGE):$(TAG)

.PHONY: help deps check test build clean
