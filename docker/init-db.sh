#!/bin/bash
# docker/init-db.sh

set -e

echo "Waiting for database..."
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