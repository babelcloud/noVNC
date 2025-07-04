# noVNC Fork: Summary of Changes

This document outlines the key modifications made to the original noVNC project. The primary goals of this fork are to harden security, simplify deployment, and automate the release process, making it suitable for production environments where configuration should be standardized and controlled.

## 1. Configuration & Security Hardening

We've fundamentally changed how noVNC is configured to reduce the attack surface and prevent users from making insecure or unintended changes.

### 1.1. Hardened WebSocket Configuration
The WebSocket connection parameters are no longer user-configurable. They are now automatically determined based on the environment.

- **Fixed Path**: The WebSocket path is now automatically generated based on the current request URI, with a `/ws` suffix appended. This prevents users from specifying arbitrary WebSocket endpoints via URL parameters.
- **Auto-Configured Host & Port**: The host and port for the WebSocket connection are implicitly the same as the web server providing the noVNC client.
- **Auto-Configured Encryption**: Encryption (`wss://` vs `ws://`) is automatically enabled based on the page protocol (`https://` vs `http://`).

### 1.2. Simplified User Interface
To enforce the hardened configuration, all related UI elements have been removed from the settings panel.

- **Hidden WebSocket Panel**: The entire "WebSocket" section in the settings panel, which included fields for Host, Port, Path, and Encrypt, is now hidden using `style="display: none;"`.
- **Removed UI Logic**: The corresponding JavaScript code for managing these UI elements and their state changes has been removed from `app/ui.js`.

### 1.3. Removed External Configuration Dependencies
To create a more self-contained and streamlined application, we have eliminated all runtime dependencies on external JSON configuration files.

- **Removed `defaults.json` and `mandatory.json`**: The application no longer attempts to fetch these files at startup. This prevents potential 404 errors and simplifies deployment, as these files no longer need to be provisioned.
- **Removed `package.json` for Versioning**: The application no longer fetches `package.json` to display the version number. This removes another unnecessary HTTP request and potential point of failure.

### 1.4. Hardcoded Version Number
To maintain version visibility without the `package.json` dependency, the version number is now hardcoded directly into `app/ui.js`.

- **Current Version**: Set to `4cb5aa4-fork`.
- **Benefit**: This provides clear version identification for debugging and support while keeping the application self-contained.

## 2. Build & Deployment System

A robust build system has been created to produce clean, production-ready artifacts that mimic the structure of official `apt` packages.

### 2.1. Production Build Script (`build.sh`)
- **Purpose**: Creates a clean distribution in the `build/` directory.
- **Process**:
  1. Cleans any previous build artifacts.
  2. Copies only the necessary runtime directories (`app`, `core`, `vendor`, `utils`, `include`).
  3. Copies the main `vnc.html` and `vnc_lite.html` files.
  4. Creates the `vnc_auto.html -> vnc.html` symbolic link for compatibility.
- **Result**: A minimal, optimized set of files ready for deployment.

### 2.2. Simplified Commands (`Makefile`)
A `Makefile` provides a simple, unified interface for all common development and deployment tasks.

- `make build`: Creates the production build in the `build/` directory.
- `make clean`: Removes all build artifacts.
- `make dist`: Creates a generic, non-versioned `novnc.tar.gz` archive containing the build content.
- `make release VERSION=x.y.z`: Creates a versioned `novnc-x.y.z.tar.gz` archive.
- `make tag VERSION=x.y.z`: Creates and pushes a Git tag, triggering the automated release workflow.
- `make install`: Installs the build to `/usr/share/novnc` (requires sudo).

### 2.3. Correct Tarball Packaging
The packaging commands (`tar -czf ... -C build .`) have been specifically crafted to archive the *contents* of the `build` directory, not the directory itself. This ensures that when the archive is extracted, it doesn't create an unnecessary parent folder.

## 3. Automated Release Workflow

Inspired by `goreleaser`, a complete CI/CD pipeline has been implemented using GitHub Actions to automate releases.

### 3.1. GitHub Actions Workflow (`.github/workflows/release.yaml`)
- **Trigger**: Automatically runs whenever a new version tag (e.g., `v1.0.0`) is pushed to the repository.
- **Permissions**: The workflow is configured with `contents: write` permissions to allow it to create GitHub Releases.
- **Process**:
  1. Checks out the tagged code.
  2. Runs the `build.sh` script to create the production build.
  3. Packages the build into a versioned `.tar.gz` artifact.
  4. Automatically generates release notes.
  5. Publishes a new GitHub Release with the tag, release notes, and the `.tar.gz` artifact as a downloadable asset.

### 3.2. Release Process
The release process is now as simple as running one command:
```bash
# This will create a Git tag, push it, and trigger the entire release process.
make tag VERSION=1.2.3
```
