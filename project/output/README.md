# Outputs

This folder contains all outputs from tests performed inside EC2 instances.

## Standalone

To run the standalone benchmark with sysbench, the following commands were used:

```bash
$ sudo sysbench oltp_read_write --table-size=1000000 --db-driver=mysql --mysql-db=sakila --mysql-user=root --mysql-password=root prepare

$ sudo sysbench oltp_read_write --table-size=1000000 --db-driver=mysql --mysql-db=sakila --mysql-user=root --mysql-password=root --threads=6 --time=60 --max-requests=0 run > /home/shared/testbench-result.log

```

The output of the test is available in the `/home/shared/testbench-result.log` file.

## Cluster

To run the cluster benchmark with sysbench, the following commands were used:

```bash
$ sudo sysbench oltp_read_write --table-size=1000000 --db-driver=mysql --mysql-db=sakila --mysql-user=root --mysql-password=root prepare

$ sudo sysbench oltp_read_write --table-size=1000000 --db-driver=mysql --mysql-db=sakila --mysql-user=root --mysql-password=root --threads=6 --time=60 --max-requests=0 run > /home/shared/testbench-result.log

```
