.PHONY: all build clean install help dist

help: ## Print help message
	@printf "\nUsage: make <command>\n"
	@grep -F -h "##" $(MAKEFILE_LIST) | grep -F -v grep -F | sed -e 's/\\$$//' | awk 'BEGIN {FS = ":*[[:space:]]*##"}; \
	{ \
		if($$2 == "") \
			pass; \
		else if($$0 ~ /^#/) \
			printf "\n%s\n", $$2; \
		else if($$1 == "") \
			printf "     %-28s%s\n", "", $$2; \
		else \
			printf "    \033[34m%-28s\033[0m %s\n", $$1, $$2; \
	}'

# Build configuration
BUILD_DIR = build
INSTALL_PREFIX = /usr/share/novnc

# Default target
all: build

# Build the distribution
build: ## Build the distribution
	@echo "Building noVNC distribution..."
	@./build.sh

# Clean build artifacts
clean: ## Clean build artifacts
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) novnc-*.tar.gz

# Install to system (requires sudo)
install: build ## Install to system (requires sudo)
	@echo "Installing noVNC to $(INSTALL_PREFIX)..."
	@sudo mkdir -p $(INSTALL_PREFIX)
	@sudo cp -r $(BUILD_DIR)/* $(INSTALL_PREFIX)/
	@echo "Installation completed. noVNC is available at $(INSTALL_PREFIX)/"

# Create a tarball for distribution
dist: build ## Create distribution tarball
	@echo "\nCreating distribution tarball..."
	@tar -czf novnc.tar.gz -C $(BUILD_DIR) .
	@echo "Tarball created: novnc.tar.gz"

# Version management
tag: ## Create and push a new version tag (usage: make tag VERSION=1.0.0)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Usage: make tag VERSION=1.0.0"; \
		exit 1; \
	fi
	@echo "Creating tag v$(VERSION)..."
	@git tag -a v$(VERSION) -m "Release v$(VERSION)"
	@echo "Pushing tag v$(VERSION) to origin..."
	@git push origin v$(VERSION)
	@echo "Tag v$(VERSION) created and pushed. GitHub Actions will build and release automatically."

release: ## Create a release build with version (usage: make release VERSION=1.0.0)
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: VERSION is required. Usage: make release VERSION=1.0.0"; \
		exit 1; \
	fi
	@echo "Building release v$(VERSION)..."
	@$(MAKE) build
	@echo "Creating versioned tarball..."
	@tar -czf novnc-$(VERSION).tar.gz -C $(BUILD_DIR) .
	@echo "Release tarball created: novnc-$(VERSION).tar.gz"

check-version: ## Check current version and tags
	@echo "Current branch: $(shell git branch --show-current)"
	@echo "Last commit: $(shell git log -1 --oneline)"
	@echo "Latest tag: $(shell git describe --tags --abbrev=0 2>/dev/null || echo 'No tags found')"
	@echo "Available tags:"
	@git tag -l | sort -V | tail -5 || echo "No tags found"
