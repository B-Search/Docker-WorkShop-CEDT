# Stage 1: build/install dependencies
FROM node:20.11-slim AS build
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --omit=dev \
 && npm update proxy-addr --no-save --omit=dev
COPY app/ ./

# Stage 2: runtime
FROM node:20.11-slim
ENV NODE_ENV=production

# Patch OS packages, then remove npm (not needed at runtime)
RUN apt-get update \
 && apt-get upgrade -y \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

WORKDIR /app
COPY --from=build /app ./
USER node
EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=5 \
  CMD node -e "require('http').get('http://localhost:3000/health',r=>process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["node", "src/index.js"]