#!/bin/sh

cd /faafo/faafo

docker-compose pull
docker-compose up -d

sleep 30s
docker run --link faafo_api_1:faafo_api_1 egifedcloud/training-fractal faafo --endpoint-url http://faafo_api_1 create --tasks 5
