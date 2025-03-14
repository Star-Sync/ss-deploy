
# Starting the services
start-logging:
	docker compose -f logging/compose.yaml -p logging-stack up -d

start-core:
	docker compose -f core/compose.yaml -p core-services up -d

start-db: create-network
	docker compose -f core/compose.yaml -p core-services up -d ss-db

start-all: create-network start-logging start-core

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
