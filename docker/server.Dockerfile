FROM node:22-alpine AS base
RUN corepack enable
WORKDIR /app

# ── dev ──
FROM base AS dev
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/server/package.json ./apps/server/
COPY packages/shared/package.json ./packages/shared/
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm --filter @handly/shared build
EXPOSE 3000
WORKDIR /app/apps/server
CMD ["pnpm", "run", "start:dev"]

# ── production ──
FROM base AS build
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/server/package.json ./apps/server/
COPY packages/shared/package.json ./packages/shared/
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm --filter @handly/shared build
RUN pnpm --filter @handly/server build

FROM node:22-alpine AS production
WORKDIR /app
COPY --from=build /app/apps/server/dist ./dist
COPY --from=build /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "dist/main"]
