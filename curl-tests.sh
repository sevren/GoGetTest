#!/bin/bash

#The following script file will hit the diffrent endpoints 

docker-compose up -d

# wait for everything to have been started.. 
sleep 5

curl -X POST -d "{\"password\":\"s3cr3t\"}" http://localhost:8080/lisa

curl -X POST -d "{\"password\":\"s3cr3t\"}" http://localhost:8080/lisa/licenses

curl -X POST -d "{\"password\":\"qwerty\"}" http://localhost:8080/john/licenses

