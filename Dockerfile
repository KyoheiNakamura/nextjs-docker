# Build Layer
FROM node:16.13.2 AS builder
WORKDIR /frontend
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Package install Layer
FROM node:16.13.2-slim As node_modules
WORKDIR /frontend
COPY package*.json ./
RUN npm ci --only=production

# Production Run Layer
FROM gcr.io/distroless/nodejs:16 AS production
# FROM gcr.io/distroless/nodejs:debug-arm64 AS production
WORKDIR /frontend
ENV NODE_ENV="production"
COPY --from=builder --chown=nonroot:nonroot /frontend/dist ./dist
COPY --from=node_modules --chown=nonroot:nonroot /frontend/node_modules ./node_modules
USER nonroot
EXPOSE 3000
CMD ["dist/main"]

# https://zenn.dev/necocoa/articles/nestjs-docker
# https://zenn.dev/kazumax4395/articles/427cc791f6145b
# https://qiita.com/taquaki-satwo/items/f8fbe8b1efc4b2323ae7
