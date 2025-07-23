# Web3 Starter Kit Makefile
# Comprehensive build automation for React + Wagmi + Foundry + Civic

.PHONY: help install dev build test lint clean
.PHONY: compile test-contracts deploy deploy-sepolia
.PHONY: civic-setup civic-test
.PHONY: test-frontend test-integration
.PHONY: docs-serve

# Default target
help:
	@echo "Web3 Starter Kit - Available Commands:"
	@echo ""
	@echo "Development:"
	@echo "  install         - Install all dependencies"
	@echo "  dev            - Start development server"
	@echo "  build          - Build for production"
	@echo "  test           - Run all tests"
	@echo "  lint           - Run linting"
	@echo "  clean          - Clean build artifacts"
	@echo ""
	@echo "Smart Contracts:"
	@echo "  compile        - Compile smart contracts"
	@echo "  test-contracts - Test smart contracts"
	@echo "  deploy         - Deploy to local network"
	@echo "  deploy-sepolia - Deploy to Sepolia testnet"
	@echo ""
	@echo "Civic Authentication:"
	@echo "  civic-setup    - Set up Civic authentication"
	@echo "  civic-test     - Test Civic integration"
	@echo ""
	@echo "Testing:"
	@echo "  test-frontend  - Run frontend tests"
	@echo "  test-integration - Run integration tests"
	@echo ""
	@echo "Documentation:"
	@echo "  docs-serve     - Serve documentation locally"

# Development commands
install:
	@echo "Installing dependencies..."
	@cd frontend && npm install
	@cd contracts && forge install
	@echo "✅ Dependencies installed successfully"

dev:
	@echo "Starting development server..."
	@cd frontend && npm run dev

build:
	@echo "Building for production..."
	@cd frontend && npm run build
	@echo "✅ Build completed"

test: test-frontend test-contracts
	@echo "✅ All tests completed"

lint:
	@echo "Running linting..."
	@cd frontend && npm run lint
	@cd contracts && forge fmt --check
	@echo "✅ Linting completed"

clean:
	@echo "Cleaning build artifacts..."
	@cd frontend && rm -rf dist node_modules
	@cd contracts && forge clean
	@echo "✅ Clean completed"

# Smart contract commands
compile:
	@echo "Compiling smart contracts..."
	@cd contracts && forge build
	@echo "✅ Contracts compiled successfully"

test-contracts:
	@echo "Testing smart contracts..."
	@cd contracts && forge test -vv
	@echo "✅ Contract tests completed"

deploy:
	@echo "Deploying to local network..."
	@cd contracts && forge script Deploy --rpc-url http://localhost:8545 --broadcast
	@echo "✅ Contracts deployed to local network"

deploy-sepolia:
	@echo "Deploying to Sepolia testnet..."
	@cd contracts && forge script Deploy --rpc-url https://sepolia.infura.io/v3/$(INFURA_PROJECT_ID) --broadcast --verify
	@echo "✅ Contracts deployed to Sepolia testnet"

# Civic authentication commands
civic-setup:
	@echo "Setting up Civic authentication..."
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@echo "📝 Please edit .env file with your Civic client ID"
	@echo "🔗 Get your client ID from: https://auth.civic.com"
	@echo "📋 Civic features available:"
	@echo "   • SSO (Google, Apple, X, Facebook, Discord, GitHub)"
	@echo "   • Email authentication"
	@echo "   • Embedded wallet capabilities"
	@echo "   • Multi-chain support"
	@echo "✅ Civic setup instructions completed"

civic-test:
	@echo "Testing Civic integration..."
	@cd frontend && npm run test:civic
	@echo "✅ Civic integration test completed"

# Testing commands
test-frontend:
	@echo "Running frontend tests..."
	@cd frontend && npm run test
	@echo "✅ Frontend tests completed"

test-integration:
	@echo "Running integration tests..."
	@cd frontend && npm run test:integration
	@echo "✅ Integration tests completed"

# Documentation
docs-serve:
	@echo "Serving documentation..."
	@cd docs && python3 -m http.server 8000
	@echo "📖 Documentation available at http://localhost:8000"

# Utility commands
format:
	@echo "Formatting code..."
	@cd frontend && npm run format
	@cd contracts && forge fmt
	@echo "✅ Code formatting completed"

type-check:
	@echo "Running type checks..."
	@cd frontend && npm run type-check
	@echo "✅ Type checks completed"

# Environment setup
setup-env:
	@echo "Setting up environment..."
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@echo "📝 Please configure your .env file"
	@echo "✅ Environment setup completed"

# Security checks
security-check:
	@echo "Running security checks..."
	@cd frontend && npm audit
	@cd contracts && forge build --sizes
	@echo "✅ Security checks completed"

# Performance checks
perf-check:
	@echo "Running performance checks..."
	@cd frontend && npm run build -- --analyze
	@echo "✅ Performance analysis completed"

# Database commands (if using local database)
db-setup:
	@echo "Setting up local database..."
	@echo "📝 Configure your database connection in .env"
	@echo "✅ Database setup instructions completed"

# Docker commands (if using Docker)
docker-build:
	@echo "Building Docker image..."
	@docker build -t web3-starter-kit .
	@echo "✅ Docker image built"

docker-run:
	@echo "Running Docker container..."
	@docker run -p 3000:3000 web3-starter-kit
	@echo "✅ Docker container running"

# Git hooks setup
setup-hooks:
	@echo "Setting up Git hooks..."
	@mkdir -p .git/hooks
	@cp scripts/pre-commit .git/hooks/
	@chmod +x .git/hooks/pre-commit
	@echo "✅ Git hooks setup completed"

# Backup commands
backup:
	@echo "Creating backup..."
	@tar -czf backup-$(shell date +%Y%m%d-%H%M%S).tar.gz frontend/src contracts/src docs
	@echo "✅ Backup created"

# Reset commands
reset:
	@echo "Resetting to clean state..."
	@make clean
	@make install
	@echo "✅ Reset completed"

# Help for specific commands
help-install:
	@echo "Install command installs all dependencies for both frontend and contracts"
	@echo "Usage: make install"

help-dev:
	@echo "Dev command starts the development server"
	@echo "Usage: make dev"

help-deploy:
	@echo "Deploy commands deploy smart contracts to different networks"
	@echo "Usage: make deploy (local) or make deploy-sepolia (testnet)"

# Version information
version:
	@echo "Web3 Starter Kit v1.0.0"
	@echo "Node.js: $(shell node --version)"
	@echo "npm: $(shell npm --version)"
	@echo "Foundry: $(shell forge --version 2>/dev/null || echo 'Not installed')" 