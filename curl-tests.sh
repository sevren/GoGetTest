#!/bin/sh

#The following script file will hit the diffrent endpoints 
docker-compose up -d rabbitmq
# wait for everything to have been started.. 
sleep 5
# Start the rest
docker-compose up -d license-manager
sleep 2
docker-compose up -d pairing-manager

echo "\n\n Sending a POST request for user lisa\n\n"
curl -v -d "{\"password\":\"s3cr3t\"}" http://localhost:8080/lisa

echo "\n\nSending a POST request for user lisa with the correct password \n\n"
curl -v  -d "{\"password\":\"s3cr3t\"}" http://localhost:8080/lisa/licenses

echo "\n\nSending a POST request for user lisa with the wrong password \n\n"
curl -v  -d "{\"password\":\"wrong-password\"}" http://localhost:8080/lisa/licenses

echo "\n\nSending a POST request for user john with the correct password \n\n"
curl -v -d "{\"password\":\"qwerty\"}" http://localhost:8080/john/licenses

echo "\n\nSending a POST request for a nonexistant user \n\n"
curl -v -d "{\"password\":\"cvxcv\"}" http://localhost:8080/omg-i-dont-exist/licenses
