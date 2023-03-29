# discord-bot-fly

repo for fly container that runs multiple discord bots

if any discord bots are high scale or important, they should be spun off into their own container

but its nice to have a single container that can run multiple bots, makes it easy to add new bots, especially if they are low scale

## how to add a new bot

1. import bot repo as a submodule
2. (optional) write script to push env vars to .env if needed
2. (optional) import or write an "environment check" script
3. add build steps to dockerfile
4. add run steps to entrypoint.sh

## how to run

test with:
`
docker compose up --build
`

fly uses the dockerfile to build its only deploy script, any additional fly-specific config can go in fly.toml. discord bots use webhooks though, so they dont need to be exposed to the internet

`
fly deploy
`