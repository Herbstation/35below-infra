#!/bin/bash

docker compose -f ./docker-compose.yaml -f ./docker-compose.prod.yaml stop
./archive.sh
