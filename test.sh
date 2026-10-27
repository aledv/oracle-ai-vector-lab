#!/usr/bin/env bash
# Checks the lab: LAB connection, SQLcl MCP server, vector search demo.
# Needs SQLcl (`sql`) on the PATH with a saved connection named by LAB_CONN (default "lab").
set -uo pipefail
cd "$(dirname "$0")" || exit 1
CONN="${LAB_CONN:-lab}"
fail=0
ok() { echo "OK   $1"; }
bad() { echo "FAIL $1"; fail=1; }

out=$(echo "select 'user='||user from dual;" | sql -S -name "$CONN" 2>&1)
if grep -q "user=LAB" <<<"$out"; then ok "connection $CONN"; else bad "connection $CONN"; fi

mcp=$( (printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1"}}}' \
    '{"jsonrpc":"2.0","method":"notifications/initialized"}' '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'; sleep 12) | timeout 40 sql -mcp 2>/dev/null)
if grep -q '"sql_run"' <<<"$mcp"; then ok "MCP server (sql_run tool listed)"; else bad "MCP server"; fi

demo=$(timeout 240 sql -S -name "$CONN" @sql/01_vector_demo.sql 2>&1 </dev/null)
first=$(grep -A4 'stole the card' <<<"$demo" | grep -m1 -E "^(accounts|cards|mortgage|savings|access)")
if grep -q "^cards" <<<"$first"; then ok "vector search (first hit: cards)"; else bad "vector search: $first"; fi
exit $fail
