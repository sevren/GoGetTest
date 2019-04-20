# GoGet AB Test

The following repo contains the bare minimum required to run the 3 challenges

* Challenge 1 - Create a micro service with a REST endpoint to retrieve licenses from a database (license-manager)
* Challenge 2 - Create a micro service with a REST endpoint to simulate pairing based on the code from Challenge 1 (pairing-manager)
* Challenge 3 - Make the 2 microservices talk, Implemented RabbitMQ functionality - license-manager is a consumer of messages, pairing-manager is a publisher of messages

The test is implemented in Go 1.12

### Regarding Challenge 3 

Challenge 3 implements functionality in both microservices from Challenges 1 and 2. 

The license-manager code has been upgraded to perform the following:

* Upon startup attempt to connect to RabbitMQ server and bind a queue to the exchange called `data`
* Start a long running concurrent thread to consume messages
* The messages consumed contain the code which was used for the pairing in Challenge 2. This will be inserted in the SQL lite databse under the table used_licenses

The pairing-manager code has been upgraded to perform the following
* Upon startup attempt to connect to the RabbitMQ server and create the exchange called `data`
* On each POST, where a code is provided the service will then send a message to RabbitMQ

If the microservices can not connect to the rabbitmq server then the rabbitMQ functionality will be disabled, however you can still use the REST endpoints as normal

## Submodules

This repo consists of 2 Git sub modules please run the following to retrieve them

`git submodule update --init --recursive`


## Prebuilt images

There are already pre-built docker hub packages implementing the services.
You should just need docker-compose and docker installed on the machine that will run this code. 

`docker run -p 8080:8080 -it sevren/license-manager`
`docker run -p 8081:8081 -it sevren/pairing-manager`

## Docker compose

There is a docker-compose configuration file which will allow you to run the system easily.

It uses my built images from DockerHub. 

Simply run the following in a terminal and it will start all the services 

`./start.sh`

Please note that the rabbit-mq dependency and the connection to the database take a few seconds. The rest controllers will be avaialble after those have started. 


## (Challenge 1) License-Manager 

A simple microservice that features a REST controller 
a connection to a SQL lite database accessed through GoRM and finally a rabbitMQ connection.

This microservice will upon startup connect to the database - sqlite3 and to the rabbitMQ exchange. 

Please note that the connection to the database can take a few seconds..

The Rest endpoint is served on the following url: 

http://localhost:8080/

A swaggerui for this is also served on 

http://localhost:9090/swaggerui

## (Challenge 2) Pairing-Manager

A simple microservice that features a REST controller, a in-memory cache and a connection to rabbitmq exchange. It corresponds to Challenge number 2. Simulating pairing a license to a device ip. 

For testing purposes we use the following HEADER `x-forwarded-for`  in GET request to simulate spoofed ip addresses. 

This microservice is a publisher of messages on the rabbitMQ exchange. 

The Rest endpoint is served on the following url: 

http://localhost:8081

A swaggerui for this is also served on 

http://localhost:9091/swaggerui

## Microservice Communication

The 2 microservices use a Message Broker - RabbitMQ (Amqp) to communicate. 

I use the management-plugin you can visually inspect that messages are being sent. 

http://localhost:15672
Login with guest/guest

You should see a custom exchange called `data`

The pairing-manager will send a message to the License manager via the RabbitMQ connection. Each message will be published on the exchange called `data`

## Curl Testing script

The following is a testing script written in bash to quickly demonstrate the functionality of the different endpoints in challenge 1
