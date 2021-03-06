# GoGet AB Test

```bash
git clone --recursive https://github.com/sevren/GoGetTest.git
```

The following repo contains the bare minimum required to run the 3 challenges

* Challenge 1 - Create a micro service with a REST endpoint to retrieve licenses from a database (license-manager)
* Challenge 2 - Create a micro service with a REST endpoint to simulate pairing based on the code from Challenge 1 (pairing-manager)
* Challenge 3 - Make the 2 microservices talk, Implemented RabbitMQ functionality - license-manager is a consumer of messages, pairing-manager is a publisher of messages

The test is implemented in Go 1.12

## Quick start

Please ensure that the following ports on your machine are not in use: 
* 8080 - Used for license-manager REST Controller
* 9090 - Used for license-manager swaggerui
* 8081 - Used for pairing-manager REST Controller
* 9091 - Used for pairing-manager swaggerui
* 5672 - used for rabbitmq message communication
* 15672 - used for rabbitmq management plugin web interface

There are already pre-built docker hub packages implementing the services.
You should just need docker-compose and docker installed on the machine that will run this code.

 ### Running without RabbitMQ

Open 2 terminals run one of these commands in each one :

`docker run -p 8080:8080 -p 9090:9090 -it sevren/license-manager`

`docker run -p 8081:8081 -p 9091:9091 -it sevren/pairing-manager`

 ### Running with RabbitMQ

Start by creating your own docker network, since our containers will attempt to connect to each other, they need to be discoverable. 

`docker network create challenge3-network`

If you want challenge 3 stuff you need to run a rabbitmq server on localhost you can use the following command:

`docker run --rm --name rabbitmq --network=challenge3-network -d -p 5672:5672 -p 15672:15672 -it rabbitmq:3.7-management-alpine`

Give it a few seconds to fully complete the rabbitmq command before you run the next commands - rabbitmq is notorious for taking time to start up

Open 2 terminals run one of these commands in each one :

We will mount the database into the container so you can see the inserted data in used_licenses

`docker run --network=challenge3-network -v $PWD/user_licenses.db:/app/user_licenses.db -p 8080:8080 -p 9090:9090 -it sevren/license-manager -amqp amqp://guest:guest@rabbitmq:5672/`


`docker run --network=challenge3-network -p 8081:8081 -p 9091:9091 -it sevren/pairing-manager -amqp amqp://guest:guest@rabbitmq:5672/`

### Running without docker

Should you not want to run the docker containers you can go into each submodule directory and run the code if you have go installed

`go run .`


## Clone with submodules

if you have an older version of git that doesnt support the recursive switch use this inside the repo
`git submodule update --init --recursive`

## Submodules

This repo consists of 2 Git sub modules:
* license-manager https://github.com/sevren/license-manager
* pairing-manager https://github.com/sevren/pairing-manager


## Avialable endpoints

* POST http://localhost:8080/{user}/licenses

`curl -d '{"password":"qwerty"}' http://localhost:8080/john/licenses`

Output

(For challenge 1)
```json
{"licenses":["cm9vbV9kaXNwbGF5","cm9vbV9maW5kZXI="]}
```

(For challenge 3) licenses are generated via hashids with a salt of user:license - see https://hashids.org/
```json
{"licenses":["B5K4A6Q0yJKKcQYULahQ83nMZeVo8N","N2YPE6lO9J11IaYiOxIJv31aL5WzKg"]}
```

* POST http://localhost:8081/pair

`curl -d '{"code":"cm9vbV9kaXNwbGF5", "device":"192.168.1.1"}' http://localhost:8081/pair`

Output

```json
{"key":"1346"}
```

* GET http://localhost:8081/pair/{code}/{magic-key}

`curl --header "X-Forwarded-For: 192.168.1.1" http://localhost:8081/pair/cm9vbV9kaXNwbGF5/1346`

Output

```json
{
    "Message": "success"
}
```

You can easily spoof the ip address by changing the value in the header. If you change it to one that hasnt made the pairing request you will get rejected

`curl --header "X-Forwarded-For: 192.168.1.255" http://localhost:8081/pair/cm9vbV9kaXNwbGF5/1346`

Output

```json
{
    "error": {
        "code": 403,
        "message": "Code rejected, - Requesting ip address not correct"
    }
}
```

### Regarding Challenge 3 

Challenge 3 implements functionality in both microservices from Challenges 1 and 2. 

The license-manager code has been upgraded to perform the following:

* Upon startup attempt to connect to RabbitMQ server and bind a queue to the exchange called `data`
* Start a long running concurrent thread to consume messages
* The messages consumed contain the code which was used for the pairing in Challenge 2. This will be inserted in the SQL lite databse under the table used_licenses

*OBS! The licenses will look diffrent if Challenge 3 is enabled. - I switched from base64 to hashids*

The pairing-manager code has been upgraded to perform the following
* Upon startup attempt to connect to the RabbitMQ server and create the exchange called `data`
* On each POST, where a code is provided the service will then send a message to RabbitMQ

If the microservices can not connect to the rabbitmq server then the rabbitMQ functionality will be disabled, however you can still use the REST endpoints as normal

### Testing challenge 3

Follow the instructions to start rabbitmq and the 2 docker services
Open Sqllite browser, open the database from the repo
Make a post to the /pair endpoint 
http://localhost:8081/pair

In SQL lite browser select the used_licenses database and click refresh. If the rabbitmq connection is working between the microservices and you have performed a POST you should see the license added to the tabled: used_licenses.

## GET used licenses endpoint

You can make a GET request toward the database to check the used licenses

`curl http://localhost:8080/usedlicenses`

Produces output similar to the following if there is licenses

```json
{
    "licenses": [
        "B5K4A6Q0yJKKcQYULahQ83nMZeVo8N",
        "N2YPE6lO9J11IaYiOxIJv31aL5WzKg"
    ]
}
```

and the following if there is no licenses

```json
{
    "licenses": []
}
```


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

For testing purposes we use the following HEADER `X-Forwarded-For`  in GET request to simulate spoofed ip addresses. 

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
