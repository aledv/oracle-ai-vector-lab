# oracle-ai-vector-lab

[![Lint](https://github.com/aledv/oracle-ai-vector-lab/actions/workflows/lint.yml/badge.svg)](https://github.com/aledv/oracle-ai-vector-lab/actions/workflows/lint.yml) [![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A small, hands-on lab for two new things in the Oracle world:

1. **Oracle AI Vector Search** (Database 23ai/26ai): store embeddings in a `VECTOR` column and
   search *by meaning* with `VECTOR_DISTANCE`, with the embeddings computed by a local
   [Ollama](https://ollama.com) model and called straight from PL/SQL (`DBMS_VECTOR`).
2. **Claude Code + the SQLcl MCP server**: let an AI assistant explore and change an Oracle
   schema through [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/)'s
   built-in MCP server, on a dedicated schema with made-up data.

Everything runs locally: Oracle Database Free and Ollama in Docker, no cloud and no API keys.

```
=== Question: "someone stole the card I use at the cash machine" ===
CATEGORY  DISTANCE TEXT
cards         0.27 I lost my debit card: how do I block it right away?
access       0.356 I forgot my online banking password, how do I reset it?
cards        0.401 Can the monthly spending limit of my credit card be raised?

=== Question in Italian: "tasso del mutuo della casa" (the rows are in English) ===
mortgage     0.404 I would like to renegotiate the rate of my first-home mortgage.
mortgage     0.525 What is the difference between a fixed and a variable rate?
```

## Contents

- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Using it with Claude Code](#using-it-with-claude-code)
- [Project structure](#project-structure)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Requirements

- Docker with Compose (about 3 GB of RAM for Oracle Free, plus the embedding model).
- [SQLcl](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/download/) 25.2 or later
  (for the MCP server) and Java 17+.
- Optional: [Claude Code](https://docs.anthropic.com/en/docs/claude-code) for the MCP part.

## Quick start

```bash
git clone https://github.com/aledv/oracle-ai-vector-lab.git && cd oracle-ai-vector-lab
cp .env.example .env && cp sql/config.sql.example sql/config.sql   # set the passwords in .env
docker compose up -d                                               # wait until oracle is "healthy"
docker compose exec ollama ollama pull bge-m3

# create the LAB schema (and let it call Ollama), as SYS
set -a; . ./.env; set +a
(cd sql && docker compose exec -T oracle sqlplus -s / as sysdba @/dev/stdin "$LAB_PASSWORD" < 00_create_lab_user.sql)

# save a SQLcl connection called "lab", then run the demo
sql /nolog <<< "conn -save lab -savepwd LAB/$LAB_PASSWORD@//localhost:1521/FREEPDB1"
sql -name lab @sql/01_vector_demo.sql
```

The demo creates a small FAQ table, computes the embeddings through Ollama and runs two
searches: one whose words do not appear in the matching row, and one in another language.

If Ollama runs elsewhere (another host, or natively on the Docker host), change the URL and
the ACL host/port in `sql/config.sql`: they are as seen from the database container.

## Using it with Claude Code

```bash
claude      # in this folder: accept the "sqlcl" MCP server from .mcp.json
```

Then ask, for example: *"connect to lab and show me the tables"*, *"find the FAQ closest to
'my card was swallowed by the ATM'"*, or *"add a category and re-run the demo"*. `CLAUDE.md`
keeps the assistant on the `lab` connection and away from destructive changes it did not make.

## Project structure

```
sql/config.sql.example    Ollama URL, ACL host/port, embedding model (copy to sql/config.sql)
sql/00_create_lab_user.sql  LAB schema, grants, network ACL for Ollama (run as SYS)
sql/01_vector_demo.sql    embed() function, FAQ table, semantic searches
docker-compose.yml        Oracle Database Free + Ollama
.mcp.json                 SQLcl MCP server for Claude Code
CLAUDE.md                 rules for Claude Code sessions in this folder
test.sh                   end-to-end check (connection, MCP server, demo)
```

## Development

```bash
./test.sh                 # needs the stack up and the "lab" connection saved
shellcheck test.sh        # linter (also in CI)
```

## Contributing

Issues and pull requests are welcome: new numbered scripts in `sql/` (e.g. RAG with
`DBMS_VECTOR_CHAIN`, HNSW/IVF vector indexes) are especially welcome. Keep the data made up.

## License

MIT, see [LICENSE](LICENSE). Oracle Database Free, SQLcl and Ollama have their own licenses.
