#!/bin/bash

# Remove existing pod and containers if they exist
podman pod rm -f skyrimai-pod || true
podman container rm -f chim-php-server xtts-api-server minime-t5 || true

# Create the pod with required ports
podman pod create --name skyrimai-pod \
    -p 8081:80 \
    -p 8020:8020 \
    -p 8082:8082

# Start PostgreSQL
podman run -d --pod skyrimai-pod \
    --name db \
    -e TZ='Europe/Berlin' \
    -e POSTGRES_DB=dwemer \
    -e POSTGRES_USER=dwemer \
    -e POSTGRES_PASSWORD=dwemer \
    -v postgres_data:/var/lib/postgresql/data \
    docker.io/pgvector/pgvector:pg16

# Start Web Server
podman run -d --pod skyrimai-pod \
    --name chim-php-server \
    -e TZ='Europe/Berlin' \
    -e DB_HOST=localhost \
    -e DB_PORT=5432 \
    -e DB_NAME=dwemer \
    -e DB_USER=dwemer \
    -e DB_PASSWORD=dwemer \
    -e APACHE_LOG_LEVEL=debug \
    -e PHP_ERROR_REPORTING='E_ALL' \
    -e PHP_DISPLAY_ERRORS='On' \
    -e PHP_LOG_ERRORS='On' \
    -e PHP_ERROR_LOG='/dev/stderr' \
    -v herika_data_ext:/var/www/html/ext \
    -v herika_data_conf:/var/www/html/conf \
    -v herika_data_soundcache:/var/www/html/soundcache \
    localhost/chim-php-server:latest

# Start XTTS Server
podman run -d --pod skyrimai-pod \
    --name xtts-api-server \
    -e TZ='Europe/Berlin' \
    -e NVIDIA_VISIBLE_DEVICES=all \
    --security-opt label=disable \
    -v xtts_data:/app/xtts-api-server/xtts-server \
    --device nvidia.com/gpu=all \
    docker.io/augustobeiro/aiff-xtts-api-server:latest \
    bash -c "cd /app/xtts-api-server && python3 -m xtts_api_server --listen -p 8020 -t 'http://localhost:8020' -sf 'xtts-server/speakers' -o 'xtts-server/output' -mf 'xtts-server/models' --deepspeed"

# Start MiniMe-T5
podman run -d --pod skyrimai-pod \
    --name minime-t5 \
    -e TZ='Europe/Berlin' \
    -e NVIDIA_VISIBLE_DEVICES=all \
    --security-opt label=disable \
    --device nvidia.com/gpu=all \
    localhost/minime-t5:latest