# syntax=docker/dockerfile:1.7
# =============================================================================
# Builder stage
# =============================================================================
FROM node:20.11-slim AS builder

WORKDIR /app

# TODO(step-4b): copy package.json and package-lock.json from the app/ folder
COPY app/package*.json ./
RUN npm ci --omit=dev

# TODO(step-4c): copy the rest of the app source from the app/ folder
COPY app/ .

# =============================================================================
# Runtime stage
# =============================================================================
FROM node:20.11-slim

WORKDIR /app

# TODO(step-4e): copy from builder
COPY --from=builder /app /app

ENV NODE_ENV=production
EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
  CMD node -e "require('http').get('http://localhost:3000/health', r => process.exit(r.statusCode===200?0:1)).on('error', () => process.exit(1))"

CMD ["node", "src/index.js"]