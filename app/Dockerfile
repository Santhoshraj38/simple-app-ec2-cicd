# Stage 1: Build Dependencies
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm ci

COPY . .

# Stage 2: Production Image
FROM node:20-alpine

WORKDIR /usr/src/app

COPY package*.json ./

# Only install production dependencies
RUN npm ci --only=production

COPY --from=builder /usr/src/app/index.js ./

EXPOSE 3000

ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "index.js"]
