#!/bin/bash

#The following script file will hit the diffrent endpoints 
docker-compose up -d rabbitmq
# wait for everything to have been started.. 
sleep 5
# Start the rest
docker-compose up 