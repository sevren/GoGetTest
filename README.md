# GoGet AB Test

The following repo contains the bare minimum required to run the 3 challenges

There are already pre-built docker hub packages implementing the services.

You should just need docker-compose and docker installed on the machine that will run this code. 

This repo consists of 2 Git sub modules please run the following to retrieve them

`git submodule update --init --recursive`

The test is implemented in Go 1.12

## License - Manager 

A simple microservice that features a REST controller 
a connection to a SQL lite database accessed through GoRM and finally a rabbitMQ connection.

This microservice will upon startup connect to the database - sqlite3 and to the rabbitMQ exchange. 

Please note that the connection to the database can takea few seconds..

The Rest endpoint is served on the following url: 

http://localhost:8080/

## Pairing - Manager

A simple microservice that features a REST controller, a in-memory cache and a connection to rabbitmq exchange. It corresponds to Challenge number 2. Simulating pairing a license to a device ip. 

For testing purposes we use the following HEADER `x-forwarded-for`  in GET request to simulate spoofed ip addresses. 

This microservice is a publisher of messages on the rabbitMQ exchange. 

The Rest endpoint is served on the following url: 

http://localhost:8081

## Microservice Communication

The 2 microservices use a Message Broker - RabbitMQ (Amqp) to communicate. 

I use the management-plugin you can visually inspect that messages are being sent. 

http://localhost:15672
Login with guest/guest

You should see a custom exchange called `data`

The pairing-manager will send a message to the License manager via the RabbitMQ connection. Each message will be published on the exchange called `data`

## Curl Testing script

The following is a testing script written in bash to quickly demonstrate the functionality of the different endpoints 


