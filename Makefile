# ==============================================================================
# Makefile: Enterprise Cloud DevOps Automation - Developer Shortcuts
# ==============================================================================
# Usage: make <target>
# Example: make deploy  |  make test  |  make backup

.PHONY: help test build deploy monitor clean backup scale dr-test swarm-status \
        terraform-validate terraform-plan

.DEFAULT_GOAL := help

# ---- Colors for output -------------------------------------------------------
BOLD  := \033[1m
RESET := \033[0m
GREEN := \033[32m
BLUE  := \033[34m
YELLOW:= \033[33m

## help: Show all available make commands
help:
	@echo ""
	@echo "$(BOLD)Enterprise Cloud DevOps Automation - Available Commands$(RESET)"
	@echo "──────────────────────────────────────────────────────────────"
	@grep -E '^## ' Makefile | sed 's/## /  make /' | column -t -s ':'
	@echo ""

# ── Local Development ─────────────────────────────────────────────────────────

## setup: Initialize local Docker Swarm, networks, and secrets
setup:
	@echo "$(BLUE)Setting up local simulation environment...$(RESET)"
	bash scripts/setup-local-simulation.sh

## build: Build the application Docker image locally
build:
	@echo "$(BLUE)Building enterprise-cloud-api container image...$(RESET)"
	docker build -t enterprise-cloud-api:latest app/
	@echo "$(GREEN)Build complete. Image: enterprise-cloud-api:latest$(RESET)"

## test: Run Python unit tests
test:
	@echo "$(BLUE)Running pytest unit tests...$(RESET)"
	pip install -q -r app/src/requirements.txt
	pytest app/tests/ -v --tb=short

# ── Docker Swarm Deployment ────────────────────────────────────────────────────

## deploy: Deploy all stacks to Docker Swarm (monitoring + application)
deploy:
	@echo "$(BLUE)Deploying all Swarm stacks...$(RESET)"
	cd docker-swarm && bash deploy-stack.sh

## monitor: Deploy only the monitoring stack (Prometheus + Grafana)
monitor:
	@echo "$(BLUE)Deploying monitoring stack...$(RESET)"
	docker stack deploy -c docker-swarm/monitoring-stack.yml monitoring

## swarm-status: Show Swarm cluster node status and all services
swarm-status:
	@echo "$(BOLD)=== Swarm Nodes ===$(RESET)"
	docker node ls 2>/dev/null || echo "Not in Swarm mode"
	@echo ""
	@echo "$(BOLD)=== All Running Services ===$(RESET)"
	docker service ls

## scale: Scale the API service (usage: make scale REPLICAS=5)
REPLICAS ?= 3
scale:
	@echo "$(BLUE)Scaling enterprise_api to $(REPLICAS) replicas...$(RESET)"
	bash scripts/scaling/scale-service.sh enterprise_api $(REPLICAS)

## clean: Gracefully remove all stacks and prune unused resources
clean:
	@echo "$(YELLOW)Removing all Swarm stacks and cleaning up...$(RESET)"
	bash scripts/ops/cleanup-stack.sh

# ── Backup & Disaster Recovery ─────────────────────────────────────────────────

## backup: Run encrypted database backup to S3
backup:
	@echo "$(BLUE)Running automated encrypted database backup...$(RESET)"
	bash scripts/backup/backup-database.sh

## dr-test: Run disaster recovery simulation and self-healing test
dr-test:
	@echo "$(YELLOW)Running DR resilience simulation test...$(RESET)"
	bash scripts/disaster-recovery/dr-simulation-test.sh

# ── Terraform Infrastructure ───────────────────────────────────────────────────

## terraform-validate: Format check and validate Terraform for all environments
terraform-validate:
	@echo "$(BLUE)Validating Terraform configurations...$(RESET)"
	terraform fmt -check -recursive terraform/ && echo "Format OK"
	cd terraform/environments/prod && terraform init -backend=false -input=false && terraform validate
	cd terraform/environments/staging && terraform init -backend=false -input=false && terraform validate
	@echo "$(GREEN)All Terraform configurations valid$(RESET)"

## terraform-plan: Generate Terraform execution plan for production
terraform-plan:
	@echo "$(BLUE)Generating Terraform plan for production...$(RESET)"
	cd terraform/environments/prod && terraform plan -out=prod.plan

# ── Git Repository ─────────────────────────────────────────────────────────────

## git-push-clean: Remove TEACH_ME folder and push to GitHub
git-push-clean:
	@echo "$(YELLOW)Removing TEACH_ME tutorial folder before push...$(RESET)"
	@if [ -d "TEACH_ME" ]; then \
		rm -rf TEACH_ME; \
		echo "TEACH_ME folder removed."; \
	fi
	git add .
	git commit -m "feat: complete enterprise cloud infrastructure and DevOps automation"
	git push origin main
	@echo "$(GREEN)Successfully pushed to GitHub!$(RESET)"
