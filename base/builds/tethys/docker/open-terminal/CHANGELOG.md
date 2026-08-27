# Changelog

All notable changes to `open-terminal` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Open Terminal Docker Compose deployment.

---

# [0.0.1] - 2026-08-26

### Added
- Initial docker-compose deployment configuration for `open-terminal`.
- Container exposes port `8000:8000` to the host network.
- Container uses image `ghcr.io/open-webui/open-terminal:latest`.
- Container configured with restart policy `unless-stopped`.

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A