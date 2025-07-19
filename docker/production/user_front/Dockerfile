# ===== Builder Stage =====
FROM public.ecr.aws/docker/library/node:22-bullseye AS builder

# Set working directory
WORKDIR /project

# Copy all source code
# Using .dockerignore at the root of the repository is recommended to exclude unnecessary files
COPY . .

# Install dependencies
RUN npm ci

# Build the application
RUN npm run build --workspace=user_front

# Prune development dependencies
RUN npm prune --production


# ===== Final Stage =====
FROM public.ecr.aws/docker/library/node:22-bullseye-slim

# Set working directory
WORKDIR /project

# Set NODE_ENV to production
ENV NODE_ENV production

# Copy necessary files from builder stage
COPY --from=builder /project/node_modules ./node_modules
COPY --from=builder /project/package.json ./package.json
COPY --from=builder /project/apps/user_front/package.json ./apps/user_front/package.json
COPY --from=builder /project/apps/user_front/.next ./apps/user_front/.next
COPY --from=builder /project/apps/user_front/public ./apps/user_front/public

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
# The command should be `npm start` inside the `apps/user_front` directory.
# We can achieve this by using the --workspace flag with npm.
CMD ["npm", "start", "--workspace=user_front"]
