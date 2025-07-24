# Stage 1: Install production dependencies
FROM node:20-slim AS deps
WORKDIR /app

# Copy package.json and lock file
COPY apps/user_front/package.json apps/user_front/package-lock.json* ./

# Install only production dependencies
RUN npm install --omit=dev

# Stage 2: Create the production image
FROM node:20-slim AS runner
WORKDIR /app

# Copy production dependencies from the 'deps' stage
COPY --from=deps /app/node_modules ./node_modules

# Copy the application's package.json
COPY apps/user_front/package.json ./package.json

# Copy the pre-built application from the CI/CD runner context
COPY apps/user_front/.next ./.next
COPY apps/user_front/public ./public

# Expose the port the app runs on
EXPOSE 3000

# The command to start the application
CMD ["npm", "start"]
