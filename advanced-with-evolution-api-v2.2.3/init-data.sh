#!/bin/bash
set -e;

# Detect which instance this is by checking for specific variables
if [ -n "${POSTGRES_EVOLUTION_NON_ROOT_USER:-}" ] && [ -n "${POSTGRES_EVOLUTION_NON_ROOT_PASSWORD:-}" ]; then
	# This is the postgres-evolution container
	NON_ROOT_USER=${POSTGRES_EVOLUTION_NON_ROOT_USER}
	NON_ROOT_PASSWORD=${POSTGRES_EVOLUTION_NON_ROOT_PASSWORD}
	DATABASE=${POSTGRES_EVOLUTION_DB}
	echo "SETUP INFO: Configuring postgres-evolution instance with user: ${NON_ROOT_USER}"
elif [ -n "${POSTGRES_NON_ROOT_USER:-}" ] && [ -n "${POSTGRES_NON_ROOT_PASSWORD:-}" ]; then
	# This is the standard postgres container
	NON_ROOT_USER=${POSTGRES_NON_ROOT_USER}
	NON_ROOT_PASSWORD=${POSTGRES_NON_ROOT_PASSWORD}
	DATABASE=${POSTGRES_DB}
	echo "SETUP INFO: Configuring postgres instance with user: ${NON_ROOT_USER}"
else
	echo "SETUP INFO: No environment variables given for postgres instances!"
	exit 0
fi

# Create the user and grant privileges
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$DATABASE" <<-EOSQL
	CREATE USER ${NON_ROOT_USER} WITH PASSWORD '${NON_ROOT_PASSWORD}';
	GRANT ALL PRIVILEGES ON DATABASE ${DATABASE} TO ${NON_ROOT_USER};
	GRANT CREATE ON SCHEMA public TO ${NON_ROOT_USER};
EOSQL

echo "SETUP INFO: Successfully configured database access for user: ${NON_ROOT_USER}"