SHELL := /bin/bash

.PHONY: cluster
cluster:
	@echo "Creating MySQL cluster..."
	@cd ./cluster && \
		terraform init && \
		terraform plan && \
		terraform apply -auto-approve

.PHONY: standalone
standalone:
	@echo "Creating standalone MySQL instance..."
	@cd ./standalone && \
		terraform init && \
		terraform plan && \
		terraform apply -auto-approve

.PHONY: proxy
proxy:
	@echo "Creating proxy..."
	@cd ./proxy && \
		terraform init && \
		terraform plan && \
		terraform apply -auto-approve