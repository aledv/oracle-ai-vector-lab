# CLAUDE.md

Guidance for Claude Code sessions opened in this folder.

## What this is

A learning lab for two things: working on an Oracle database through the **SQLcl MCP server**, and
**AI Vector Search** in Oracle Database 23ai/26ai with embeddings computed by Ollama and called
from PL/SQL. Explain what you do and why, and show the SQL you run.

## Setup

- Schema `LAB`, reached through a SQLcl saved connection named `lab` (`sql -name lab`).
- `.mcp.json` starts the SQLcl MCP server (`sql -mcp`); accept it when Claude Code asks.
- `embed(text)` (created by `sql/01_vector_demo.sql`) returns a vector from Ollama (`bge-m3`, 1024 dims).
- Local addresses are in `sql/config.sql` (not in git, see `sql/config.sql.example`).

## Rules

- Use only the `lab` connection. Do not connect to other schemas and do not ask for other credentials.
- Made-up data only: everything a query returns reaches the model.
- Ask before DROP or DELETE on objects you did not create in this session.
- Scripts worth keeping go in `sql/`, numbered and re-runnable, ending with `exit`.
- This is a public repository: no hostnames, IPs, passwords or personal data in tracked files.

## Check

`./test.sh` (connection, MCP server, vector search demo). Run it after changing the scripts in `sql/`.
