#!/bin/sh

cd /faafo/faafo

docker-compose pull

MASTER_HOST="PUT_HERE_THE_MASTER_IP"

ENDPOINT_URL="http://$MASTER_HOST"
TRANSPORT_URL="amqp://guest:guest@$MASTER_HOST:5672/"


docker run -d -e "ENDPOINT_URL=$ENDPOINT_URL" -e "TRANSPORT_URL=$TRANSPORT_URL" egifedcloud/training-fractal faafo-worker
