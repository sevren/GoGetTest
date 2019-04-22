#!/bin/bash

#The following script file will hit the diffrent endpoints 
docker-compose up -d rabbitmq
# wait for everything to have been started.. 
echo "Sleeping for a bit, rabbitmq takes some time to start up :("
sleep 10
# Start the rest
docker-compose up -d license-manager
sleep 2
docker-compose up -d pairing-manager
docker-compose logs -f license-manager pairing-manager