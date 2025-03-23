# 35 Below Infrastructure

Docker images and configuration for 35 Below's DreamDaemon and Browserassets CDN.

## Development Startup

1. `git submodule init`
2. `git submodule update`
3. `docker compose up --build`

## Production Setup

1. `./update.sh`
2. `./compile.sh`
3. `./start.sh`

to stop, run `./stop.sh`

## Nonfree Patches

Whenever a `nonfree-patches.tar` exists in the root of this repository, the `./compile.sh` script will extract it over the contents of the `goonstation` submodule.
