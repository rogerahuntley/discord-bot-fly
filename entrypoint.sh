#!/bin/bash

set -e

# Initialize an empty arrays to store bot states
failed_bots=()
successful_bots=()

# --- AI DISCORD BOT ---

cd /app/ai-discord-bot

# Set environment variables
declare -A env_vars=(
  ["DISCORD_BOT_TOKEN"]="AI_DISCORD_BOT_TOKEN"
  ["DISCORD_CLIENT_SECRET"]="AI_DISCORD_CLIENT_SECRET"
  ["DISCORD_CLIENT_ID"]="AI_DISCORD_CLIENT_ID"
  ["OPENAI_API_KEY"]="OPENAI_API_KEY"
)

for app_var in "${!env_vars[@]}"; do
  fly_var="${env_vars[$app_var]}"
  if [ -n "${!fly_var}" ]; then
    echo "$app_var=${!fly_var}" >> .env
  fi
done

# Check environment variables
if node devops/checkEnvironment.js; then
  # Run migrations
  npx prisma migrate deploy

  # Set up prisma
  npx prisma generate

  # Register the bot with the Discord API
  npm run register

  # Start the application with PM2
  pm2 start index.js --name ai-discord-bot

  successful_bots+=("ai-discord-bot")
else
  failed_bots+=("ai-discord-bot")
fi

# --- DOG BRIBES DISCORD BOT ---

cd /app/dog-bribes-discord-bot

# Set environment variables
declare -A env_vars=(
  ["DISCORD_BOT_TOKEN"]="DB_DISCORD_BOT_TOKEN"
  ["DISCORD_CLIENT_SECRET"]="DB_DISCORD_CLIENT_SECRET"
  ["DISCORD_CLIENT_ID"]="DB_DISCORD_CLIENT_ID"
  ["DB_SITE"]="DB_SITE"
  ["DB_EMAIL"]="DB_EMAIL"
  ["DB_PASSWORD"]="DB_PASSWORD"
)

for app_var in "${!env_vars[@]}"; do
  fly_var="${env_vars[$app_var]}"
  if [ -n "${!fly_var}" ]; then
    echo "$app_var=${!fly_var}" >> .env
  fi
done

# Check environment variables
if node devops/checkEnvironment.js; then

  # Register the bot with the Discord API
  npm run register

  # Start the application with PM2
  pm2 start index.js --name dog-bribes-discord-bot

  successful_bots+=("dog-bribes-discord-bot")
else
  failed_bots+=("dog-bribes-discord-bot")
fi

# --- START PM2 ---

cd /app

# Print the failed bots before running pm2 logs
if [ ${#failed_bots[@]} -gt 0 ]; then
  echo "The following bots failed to start due to environment check:"
  printf "%s\n" "${failed_bots[@]}"
fi

# Print the successful bots before running pm2 logs
if [ ${#successful_bots[@]} -gt 0 ]; then
  echo "The following bots started successfully:"
  printf "%s\n" "${successful_bots[@]}"
fi

# if no bots started successfully, exit with error code 1
if [ ${#successful_bots[@]} -eq 0 ]; then
  exit 1
fi

# Use the `pm2 logs` command to stream the logs of the PM2 process to the container logs
pm2 logs
