#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER misp2;
    CREATE DATABASE misp2db;
    GRANT ALL PRIVILEGES ON DATABASE misp2db TO misp2;
EOSQL

