##################################
# Stage 1: Build Stage
##################################
FROM node:18-alpine AS builder

LABEL maintainer="Robin Sharma <sharma0211kum@gmail.com>" \
      app="gemini" \
      stage="build"

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm ci

# Copy application source and build
COPY . .
RUN npm run build

# Remove dev dependencies and clean cache
RUN rm -rf node_modules && npm cache clean --force

##################################
# Stage 2: Production Stage
##################################
FROM node:18-alpine AS production

LABEL maintainer="Amitabh Soni <sharma0211kum@gmail.com>" \
      app="gemini" \
      stage="production"

WORKDIR /app

# Install only production dependencies
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev && npm cache clean --force

# Copy only necessary files from builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.mjs ./

ENV NODE_ENV=production

EXPOSE 3000

CMD ["npm", "start"]
