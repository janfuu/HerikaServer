#!/bin/bash
# docker/entrypoint.sh

set -e

# Start Apache in the background
apache2ctl start

# Wait for PostgreSQL to be ready
/usr/local/bin/wait-for-it db:5432

# Check if schema exists and create if needed
echo "Checking database schema..."
SCHEMA_EXISTS=$(PGPASSWORD=dwemer psql -h db -U dwemer -d dwemer -t -c "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = 'public';")

if [ "$SCHEMA_EXISTS" -eq "0" ]; then
    echo "Public schema doesn't exist, creating..."
    PGPASSWORD=dwemer psql -h db -U dwemer -d dwemer -c "CREATE SCHEMA IF NOT EXISTS public;"
    PGPASSWORD=dwemer psql -h db -U dwemer -d dwemer -c "ALTER SCHEMA public OWNER TO dwemer;"
fi

# Check if database needs initialization
TABLES=$(PGPASSWORD=dwemer psql -h db -U dwemer -d dwemer -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';")

if [ "$TABLES" -eq "0" ]; then
    echo "Database is empty, initializing with dwemer.sql..."
    PGPASSWORD=dwemer psql -h db -U dwemer -d dwemer -f /var/www/html/data/dwemer.sql
    if [ $? -eq 0 ]; then
        echo "Database initialization successful"
    else
        echo "Database initialization failed"
        exit 1
    fi
fi

echo "Starting log tail..."
# Store PIDs for cleanup
tail -f /var/log/apache2/access.log &
ACCESS_PID=$!
tail -f /var/log/apache2/error.log &
ERROR_PID=$!

cleanup() {
    echo "Cleaning up processes..."
    kill $ACCESS_PID $ERROR_PID 2>/dev/null || true
}

# Handle both EXIT and WINCH
trap cleanup EXIT WINCH

echo "Entering wait loop..."
# Wait forever, but check if tail processes die
while kill -0 $ACCESS_PID 2>/dev/null && kill -0 $ERROR_PID 2>/dev/null; do
    sleep 1
done

echo "One of the tail processes died, exiting..."
exit 1