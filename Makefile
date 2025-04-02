# Starting the services
start-logging:
	docker compose -f logging/compose.yaml -p logging-stack up -d
setup-logging: start-logging
	@echo "Waiting for Graylog to be ready..."
	@until curl -s http://localhost:9000/api/ | jq -r '.cluster_id' | grep -q -v "null"; do \
		echo "Graylog is not ready yet..."; \
		sleep 5; \
	done
	@echo "Graylog is ready!"
	@echo "Initializing Graylog inputs..."
	@logging/create_graylog_inputs.sh

start-core:
	docker compose -f core/compose.yaml -p core-services up -d

install-dependencies:
	@if ! command -v jq >/dev/null 2>&1; then \
		echo "Installing jq..."; \
		if [ -f /etc/debian_version ]; then \
			sudo apt-get update && sudo apt-get install -y jq; \
		elif [ -f /etc/redhat-release ]; then \
			sudo yum install -y jq; \
		elif [ -f /etc/arch-release ]; then \
			sudo pacman -S --noconfirm jq; \
		elif command -v brew >/dev/null 2>&1; then \
			brew install jq; \
		else \
			echo "Could not determine package manager. Please install jq manually."; \
			exit 1; \
		fi; \
	fi

setup-db: start-core
	@echo "Waiting for Core services to be ready..."
	@until curl -s http://localhost:8000/api/v1/hello/ -H 'accept: application/json' > /dev/null 2>&1; do \
		echo "Core services are not ready yet..."; \
		sleep 5; \
	done
	@echo "Core services are ready!"
	@echo "Initializing database..."
	@curl -s -X 'GET' 'http://localhost:8000/api/v1/hello/initdb' -H 'accept: application/json'
	@echo "Database initialized!"

start-db: create-network
	docker compose -f core/compose.yaml -p core-services up -d ss-db

start-all: install-dependencies create-network setup-logging start-core setup-db

# Stopping the services
stop-logging:
	docker compose -f logging/compose.yaml -p logging-stack down

stop-core:
	docker compose -f core/compose.yaml -p core-services down

stop-all: stop-logging stop-core

# Pull the images
pull-logging:
	docker compose -f logging/compose.yaml -p logging-stack pull

pull-core:
	docker compose -f core/compose.yaml -p core-services pull

pull-all: pull-logging pull-core

# Network
create-network:
	@docker network inspect star-sync_star-sync >/dev/null 2>&1 || \
	docker network create --driver bridge --attachable star-sync_star-sync

destroy-network:
	docker network rm star-sync_star-sync

# Shortcuts
run: start-all

stop: stop-all

pull: pull-all

clean: stop-all destroy-network
