#!/bin/bash

get_auth_token() {
  echo "Attempting to get auth token..."
  local response=$(curl -s -u "admin:admin" \
    -X POST "http://localhost:9000/api/system/sessions" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -H 'X-Requested-By: cli-script' \
    -d '{"username": "admin", "password": "admin"}')

  if [ -z "$response" ]; then
    echo "Error: No response from Graylog server" >&2
    exit 1
  fi

  local token=$(echo $response | jq -r '.session_id')
  if [ -z "$token" ] || [ "$token" = "null" ]; then
    echo "Error: Could not extract session ID from response" >&2
    echo "Response was: $response" >&2
    exit 1
  fi

  # Only output the token itself, no debug information
  echo "$token"
}

create_syslog_udp_input() {
  local auth_token=$1
  echo "Creating input with auth token: ${auth_token}"

  local input_payload='{
    "title": "NEW pygelf",
    "global": true,
    "type": "org.graylog2.inputs.gelf.tcp.GELFTCPInput",
    "configuration": {
      "port": 12201,
      "bind_address": "0.0.0.0",
      "recv_buffer_size": 262144,
      "number_worker_threads": 12,
      "override_source": null,
      "charset_name": "UTF-8",
      "decompress_size_limit": 8388608
    },
    "node": null
  }'

  # Clean up the auth token to ensure we only get the session ID
  auth_token=$(echo "${auth_token}" | grep -o '[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}')

  local response=$(curl -v -s -X POST "http://localhost:9000/api/system/inputs" \
    -H "Content-Type: application/json" \
    -H "X-Requested-By: cli-script" \
    -b "authentication=${auth_token}" \
    -d "${input_payload}")

  echo "Create input response: ${response}"
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it first."
    exit 1
fi

# Check if Graylog is accessible
if ! curl -s "http://localhost:9000" > /dev/null; then
    echo "Error: Cannot connect to Graylog at http://localhost:9000"
    echo "Make sure Graylog is running and accessible"
    exit 1
fi

# Main execution
echo "Starting script execution..."
auth_token=$(get_auth_token)
if [ -n "$auth_token" ]; then
    echo "Successfully got auth token"
    create_syslog_udp_input "${auth_token}"
else
    echo "Failed to get auth token"
    exit 1
fi
