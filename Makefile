.PHONY: help status update-all clean

help: ## Shows all commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

status: ## Shows all containers status (docker ps -a)
	docker ps -a

update-all: ## Updates all services ("docker compose pull && docker compose up -d" in each folder)
	@for dir in $$(ls -d */); do \
		if [ -f "$$dir/docker-compose.yml" ] || [ -f "$$dir/docker-compose.yaml" ]; then \
			echo ">> Updating $$dir"; \
			if [ -f "$$dir/Dockerfile" ]; then \
				echo ">>>> Dockerfile detected, composing using --build flag"; \
				(cd "$$dir" && docker compose build --pull && docker compose up -d); \
			else \
				echo ">>>> No Dockerfile detected, pulling image"; \
				(cd "$$dir" && docker compose pull && docker compose up -d); \
			fi; \
		fi \
	done

down-all: ## Stops all services
	@for dir in $$(ls -d */); do \
		if [ -f "$$dir/docker-compose.yml" ] || [ -f "$$dir/docker-compose.yaml" ]; then \
			echo ">> Stopping $$dir"; \
			(cd "$$dir" && docker compose down); \
		fi \
	done

restart-all: ## Restarts all services
	@for dir in $$(ls -d */); do \
		if [ -f "$$dir/docker-compose.yml" ] || [ -f "$$dir/docker-compose.yaml" ]; then \
			echo ">> Restarting $$dir"; \
			(cd "$$dir" && docker compose up -d); \
		fi \
	done

clean: ## Prunes all unused Docker images (docker system prune -af)
	docker system prune -af
