# Scripts

This directory contains scripts used for the development of the project.

## `startup.sh`

This script is called inside every container to start our basic service

## `docker.sh`

This script launches both the requests and metrics containers

## `terraform.sh`

This script launches our terraform infrastructure

It can be used with the following arguments

```bash
./terraform.sh [up|down]
```