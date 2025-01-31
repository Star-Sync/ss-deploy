start-logging:
	docker compose -f logging/compose.yaml -p logging-stack up -d

start-core:
	docker compose -f core/compose.yaml -p core-services up -d

start-user-mgmt:
	docker compose -f user-mgmt/compose.yaml -p user-mgmt up -d

start-all: create-network start-logging start-core start-user-mgmt

create-network:
	@docker network inspect star-sync_star-sync >/dev/null 2>&1 || \
	docker network create --driver bridge --attachable star-sync_star-sync

stop-all:
	docker compose -p user-mgmt down
	docker compose -p core-services down
	docker compose -p logging-stack down

run: start-all

stop: stop-all

clean: stop-all
	docker network rm star-sync_star-sync
