# Base image
FROM node:18

# Install PM2
RUN npm install -g pm2

RUN mkdir -p /db

# --- AI DISCORD BOT ---

# Set the working directory
WORKDIR /app/ai-discord-bot

# Copy only package.json and package-lock.json files to the working directory
COPY ai-discord-bot/package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Install lib dependencies
WORKDIR /app/ai-discord-bot/lib/ai

# Copy only package.json and package-lock.json files to the lib directory
COPY ai-discord-bot/lib/ai/package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Back to app
WORKDIR /app/ai-discord-bot

# Copy the rest of the application code to the working directory
COPY ./ai-discord-bot .

# Create symlink to mount /app/ai-discord-bot/prisma/db to /db/ai-discord-bot
RUN ln -s /app/ai-discord-bot/prisma/db /db/ai-discord-bot

# Clean Cache
RUN npm cache clean --force

# --- DOG BRIBES DISCORD BOT ---

# Set the working directory
WORKDIR /app/dog-bribes-discord-bot

# Copy only package.json and package-lock.json files to the working directory
COPY dog-bribes-discord-bot/package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy the rest of the application code to the working directory
COPY ./dog-bribes-discord-bot .

# Clean Cache
RUN npm cache clean --force

# --- GENERAL ---

WORKDIR /app

COPY ./entrypoint.sh .

# Set the entrypoint script
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]