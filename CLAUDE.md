# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Handly is a TypeScript monorepo using **pnpm workspaces** with three packages:
- `apps/server` — **@handly/server**: NestJS 11 backend with Redis (ioredis), SWC compiler, Zod validation
- `apps/client` — **@handly/client**: React 19 SPA with Vite 7
- `packages/shared` — **@handly/shared**: Shared library bundled with tsup (CJS + ESM + types)

Both apps depend on `@handly/shared` via `workspace:*`.

## Common Commands

```bash
# Install dependencies
pnpm install

# Development (shared must be built/watching before apps)
pnpm build:shared          # Build shared package once
pnpm dev:shared            # Watch mode for shared package
pnpm dev:server            # NestJS watch mode (apps/server)
pnpm dev:client            # Vite dev server (apps/client)

# Docker (full environment: Redis + Server + Client)
pnpm docker:up             # Start all services
pnpm docker:down           # Stop all services
pnpm docker:build          # Rebuild Docker images

# Formatting (root-level)
pnpm format                # Prettier on TS, JSON, YAML files

# Server-specific (run from apps/server)
pnpm lint                  # ESLint with --fix
pnpm test                  # Jest unit tests
pnpm test:watch            # Jest watch mode
pnpm test:cov              # Jest with coverage
pnpm test:e2e              # Supertest e2e tests (jest --config ./test/jest-e2e.json)

# Client-specific (run from apps/client)
pnpm lint                  # ESLint
pnpm build                 # tsc -b && vite build
```

## Architecture

**Build dependency chain**: `@handly/shared` must be built before server or client can run. The shared package outputs to `dist/` with dual CJS/ESM format and type declarations.

**Server**: NestJS with SWC builder (configured in `.swcrc` with decorator metadata). Environment variables are validated at startup via Zod schemas in `src/configs/index.ts`. Required env vars: `NODE_ENV`, `PORT`, `LOG_LEVEL`, `CORS_ORIGIN`, `REDIS_HOST`, `REDIS_PORT`.

**Client**: Vite dev server binds to `0.0.0.0` with watch polling enabled for Docker volume compatibility. Port configured via `CLIENT_PORT` env var (default 5173).

**Docker**: Multi-stage Dockerfiles in `docker/` with `dev` and production targets. Services defined in separate YAML files under `services/` and composed via `docker-compose.yaml` includes. Redis has a health check that server depends on.

## Code Style

- Prettier: single quotes, no semicolons, trailing commas, 120 char width
- TypeScript strict mode in all packages
- ESLint with typescript-eslint in both apps
- Node.js 22, TypeScript 5.7+
