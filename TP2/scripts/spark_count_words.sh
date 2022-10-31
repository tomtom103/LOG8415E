#!/bin/bash 

set -e

python3 word_count_spark.py $1 &> /dev/null 
