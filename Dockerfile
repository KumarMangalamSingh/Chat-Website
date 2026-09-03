# Monolith: Vite frontend + Express API
# Build from repository root


# ============================================================
# Stage 1: Build the Vite frontend
# ============================================================

FROM node:22-bookworm-slim AS frontend-build

WORKDIR /app/frontend

# Copy frontend package files
COPY ["Chat Frontend/package.json", "Chat Frontend/package-lock.json", "./"]

RUN npm install --no-audit --no-fund --legacy-peer-deps

# Copy frontend source
COPY ["Chat Frontend/", "./"]

# Browser calls the backend through the same host
ENV VITE_API_URL=

# Clerk public key
ARG VITE_CLERK_PUBLISHABLE_KEY
ENV VITE_CLERK_PUBLISHABLE_KEY=$VITE_CLERK_PUBLISHABLE_KEY

# Build Vite application
RUN npm run build


# ============================================================
# Stage 2: Build the Express backend
# ============================================================

FROM node:22-bookworm-slim AS backend-build

WORKDIR /app

# Copy backend package files
COPY ["ChatApp Backend/package.json", "ChatApp Backend/package-lock.json", "./"]

RUN npm install --no-audit --no-fund

# Copy backend source
COPY ["ChatApp Backend/", "./"]

# Build backend
RUN npm run build


# ============================================================
# Stage 3: Production runtime
# ============================================================

FROM node:22-bookworm-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3001

# Copy backend package files
COPY ["ChatApp Backend/package.json", "ChatApp Backend/package-lock.json", "./"]

# Install only production dependencies
RUN npm install --omit=dev --no-audit --no-fund \
    && npm cache clean --force

# Copy built backend
COPY --from=backend-build /app/dist ./dist

# Copy built frontend into backend's public directory
COPY --from=frontend-build /app/frontend/dist ./public

EXPOSE 3001

USER node

CMD ["node", "dist/index.js"]