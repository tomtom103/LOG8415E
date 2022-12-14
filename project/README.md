# Personal Project

## Description

For this project, we need to setup MySQL cluster on Amazon EC2 and implement Cloud patterns.

I have chosen to implement the Proxy pattern. 

## Getting Started

### Standalone

```bash
$ cd terraform/cluster
$ terraform init && terraform plan && terraform plan -auto-approve
```

This can also be done using the makefile

```bash
$ cd terraform && make standalone
```

The standalone deployment does everything + runs the sysbench benchmark.

### Cluster

```bash
$ cd terraform/cluster
$ terraform init && terraform plan && terraform plan -auto-approve
```

This can also be done using the makefile

```bash
$ cd terraform && make proxy
```

You should see the IP addresses of all the instances in the output.

In the event that the `null_resources` timeout, this is fine. The instances are created and the script will finish regardless.
This usually happens in case of poor network connectivity.

Once all IP addresses are visible in the output, you can include them in a `.env` file at the root of the `project/` directory.

An example `.env` file is provided in the `project/` directory. See the `example.env` file.

In the event that you encounter a timeout error, you can run the following command to get the IP addresses of the instances.

```bash
$ terraform output
```

### Docker

Next step is to build the docker image.

```bash
$ cd project/
$ docker build -t proxy:latest .
```

Once the docker image is built, it can be pushed to Docker Hub or any other registry.

```bash
$ docker tag proxy:latest <your-registry>/proxy:latest
$ docker push <your-registry>/proxy:latest
```

This image will be used to deploy the proxy on an EC2 instance.

Warning: The docker image includes the `labsuser.pem` file. This is a private key that should not be shared. Pushing this image to a public registry while the key is still valid is not recommended.

The image name should also be added to the `.env` file.

### Deploying the proxy

Make sure that the `.env` file is present and populated or this step will fail.

Also make sure that the image is available on the registry + 

```bash
$ cd terraform/proxy
$ terraform init && terraform plan && terraform plan -auto-approve
```

This can also be done using the Makefile.

```bash
$ cd terraform && make proxy
```

Once the proxy is deployed, it should be accessible on port `80` on the IP address of the instance.

## Testing the proxy

For the purpose of this demo, we have implemented the following endpoints:

- GET `/` - Returns a simple 200 response
- GET `/api/film` - Returns the list of films from the `sakila` database
- GET `/api/film/{id}` - Returns a single film from the `sakila` database
- POST `/api/raw` - Send a raw SQL query to the database

This can be tested using `httpie` or `curl`.

```bash
$ http GET http://<proxy-ip>/
HTTP/1.1 200 OK
content-length: 15
content-type: application/json
date: Wed, 14 Dec 2022 01:58:04 GMT
server: uvicorn

"Hello, world!"
```

```bash
$ http GET http://<proxy-ip>/api/film/10 X-Cluster-Mode:random
HTTP/1.1 200 OK
content-length: 385
content-type: application/json
date: Wed, 14 Dec 2022 02:00:15 GMT
server: uvicorn

{
    "description": "A Action-Packed Tale of a Man And a Lumberjack who must Reach a Feminist in Ancient China",
    "film_id": 10,
    "language_id": 1,
    "last_update": "2006-02-15T05:03:42",
    "length": 63,
    "original_language_id": null,
    "rating": "NC-17",
    "release_year": 2006,
    "rental_duration": 6,
    "rental_rate": 4.99,
    "replacement_cost": 24.99,
    "special_features": "Trailers,Deleted Scenes",
    "title": "ALADDIN CALENDAR"
}

$ http POST http://<proxy-ip>/api/raw X-Cluster-Mode:ping sql="SELECT * FROM film LIMIT 2"
HTTP/1.1 200 OK
content-length: 789
content-type: application/json
date: Wed, 14 Dec 2022 01:59:43 GMT
server: uvicorn

[
    {
        "description": "A Epic Drama of a Feminist And a Mad Scientist who must Battle a Teacher in The Canadian Rockies",
        "film_id": 1,
        "language_id": 1,
        "last_update": "2006-02-15T05:03:42",
        "length": 86,
        "original_language_id": null,
        "rating": "PG",
        "release_year": 2006,
        "rental_duration": 6,
        "rental_rate": 0.99,
        "replacement_cost": 20.99,
        "special_features": "Deleted Scenes,Behind the Scenes",
        "title": "ACADEMY DINOSAUR"
    },
    {
        "description": "A Astounding Epistle of a Database Administrator And a Explorer who must Find a Car in Ancient China",
        "film_id": 2,
        "language_id": 1,
        "last_update": "2006-02-15T05:03:42",
        "length": 48,
        "original_language_id": null,
        "rating": "G",
        "release_year": 2006,
        "rental_duration": 3,
        "rental_rate": 4.99,
        "replacement_cost": 12.99,
        "special_features": "Trailers,Deleted Scenes",
        "title": "ACE GOLDFINGER"
    }
]
```

More endpoints can be added later on if needed.