# syntax=docker/dockerfile:1.7

# TODO(step-4a): Stage 1 - Builder
FROM node:20.11-slim AS builder

# TODO(step-4b): Set working directory
WORKDIR /app

# TODO(step-4c): Copy package dependencies
COPY app/package*.json ./

# TODO(step-4d): Install dependencies
RUN npm ci

# TODO(step-4e): Copy app source code
COPY app/ .

# TODO(step-4f): Stage 2 - Runner
FROM node:20.11-slim AS runner

WORKDIR /app

# Copy built code from builder stage
COPY --from=builder /app ./

# TODO(step-4g): Expose port & add HEALTHCHECK (Node.js one-liner for node:20.11-slim)
EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (res) => res.statusCode === 200 ? process.exit(0) : process.exit(1))"

CMD ["npm", "start"]