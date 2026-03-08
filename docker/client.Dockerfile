FROM node:22-alpine AS base
RUN corepack enable
WORKDIR /app

# ── dev ──
FROM base AS dev
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/client/package.json ./apps/client/
COPY packages/shared/package.json ./packages/shared/
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm --filter @handly/shared build
EXPOSE 5173
WORKDIR /app/apps/client
CMD ["pnpm", "run", "dev", "--host"]

# ── production ──
FROM base AS build
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/client/package.json ./apps/client/
COPY packages/shared/package.json ./packages/shared/
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm --filter @handly/shared build
RUN pnpm --filter @handly/client build

FROM nginx:alpine AS production
COPY --from=build /app/apps/client/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
