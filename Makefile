start-logging:
    docker compose -f logging/compose.yaml -p logging-stack up -d

start-core:
    docker compose -f core/compose.yaml -p core-services up -d

start-user-mgmt:
    docker compose -f user-mgmt/compose.yaml -p user-mgmt up -d

start-all: start-logging start-core start-user-mgmt

stop-all:
    docker compose -p user-mgmt down
    docker compose -p core-services down
    docker compose -p logging-stack down
