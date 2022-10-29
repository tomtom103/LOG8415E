# This is the second assignment for the LOG8415E course.

Instructions on how to launch our environment and tests are available in the [tp2.pdf](tp2.pdf) file.

# Too Long Didnt Read:

You need to have terraform installed on your machine. You can download it from [here](https://www.terraform.io/downloads.html).

You also need to have an authenticated AWS CLI. You can paste your credentials in the [login.sh](scripts/login.sh) file and execute it.

## Terraform:

In order to deploy the EC2 instance with terraform, two things are needed:

- An authenticated AWS CLI (See [TLDR Section](#too-long-didnt-read))
- The private key `labuser.pem` provided by AWS at the root of the `TP2` folder. 

If you get an error about the key not being restricted enough, the following command can be run:

```bash
chmod 400 labuser.pem
```

Terraform will output the public DNS address of the EC2 instance, which can then be used to connect to the instance via SSH:

```bash
ssh -i labuser.pem ubuntu@my-ec2-public-dns.com
```

## Docker

We created our own Dockerfile containing all required dependencies to avoid having to install dependencies on each computer. This allows us to make sure that Hadoop and PySpark work properly no matter the operating system.

To build the docker image:

```bash
docker build -t inf8415_tp2:latest .
```

To launch the docker image:

```bash
docker run -it -p 50070:50070 -p 8088:8088 log8415_tp2:latest
```

The `run-docker.sh` file can also be used to launch the docker image.

## Makefile:

Multiple options are available to run the different tests scenarios. The following commands are implemented:

- `hadoop_vs_linux`: Configures hadoop to be launched in standalone mode and creates `input/` and `output/` dfs directories with hdfs.
    - Using the provided mapreduce examples that come with hadoop, we run the wordcount example with the `pg4300.txt` file.
    - We also run it with bash commands directly, we use the `awk` language to separate words into their own line, the result is piped, sorted, and we show 10 words.

- `hadoop_vs_spark`: Launches hadoop in standalone mode + installs `pyspark`. This command should run inside the EC2 container.
    - We first run the wordcount again on the `dataset[0-8].txt` files and get the execution time
    - We do the same using `pyspark` 
    - Execution times are compared between both programs

## People you might know algorithm:

TODO: Explain this


To run a command, you can do `make [command]` after starting the docker image (See [Docker](#docker))

