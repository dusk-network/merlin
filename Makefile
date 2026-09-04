help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

fmt: ## Format code
	@cargo fmt --all $(if $(CHECK),-- --check,)

clippy: ## Run Clippy
	@cargo clippy --all-targets --all-features -- -D warnings

cq: ## Run code-quality checks
	@$(MAKE) fmt CHECK=1
	@$(MAKE) clippy

test: ## Run the complete test suite
	@cargo test --all-features

no-std: ## Verify no_std compatibility
	@rustup target add wasm32-unknown-unknown 2>/dev/null || true
	@cargo build --no-default-features --target wasm32-unknown-unknown

doc: ## Build documentation without warnings
	@RUSTDOCFLAGS="-D warnings" cargo doc --all-features --no-deps

coverage: ## Report test coverage
	@cargo llvm-cov --all-features --summary-only

clean: ## Clean build artifacts
	@cargo clean

.PHONY: help fmt clippy cq test no-std doc coverage clean
