#!/usr/bin/env bash
set -euo pipefail

# Este script roda somente na primeira inicialização de um volume PostgreSQL vazio.
# Ele cria um usuário sem privilégios de superusuário para o n8n.
if [[ -z "${POSTGRES_NON_ROOT_USER:-}" || -z "${POSTGRES_NON_ROOT_PASSWORD:-}" ]]; then
  echo "ERRO: POSTGRES_NON_ROOT_USER e POSTGRES_NON_ROOT_PASSWORD são obrigatórios." >&2
  exit 1
fi

psql \
  --set=ON_ERROR_STOP=1 \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  --set=app_user="$POSTGRES_NON_ROOT_USER" \
  --set=app_password="$POSTGRES_NON_ROOT_PASSWORD" <<'EOSQL'
SELECT format('CREATE USER %I WITH PASSWORD %L', :'app_user', :'app_password') \gexec
SELECT format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I', current_database(), :'app_user') \gexec
SELECT format('GRANT USAGE, CREATE ON SCHEMA public TO %I', :'app_user') \gexec
EOSQL
