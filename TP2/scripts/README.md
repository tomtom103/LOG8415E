# Scripts

This directory contains scripts used for the development of the project.

## `configure_instance.sh`

This script is called inside every container to install all required dependencies

## `setup_functions.sh`

Allows us to create different functions which can then be called by the Makefile file.

## `hadoop_count_words.sh`

Allows us to run the wordcount example provided by hadoop on a file. The script takes 3 inputs:

- The file name with extension (e.g. dataset0.txt)
- The file name without extension (e.g. dataset0)
- The index corresponding to the number of times we have run the same file (e.g. 4 if we're on the 4th run of the same file)

## `spark_count_words.sh`

Allows us to run the `word_count_spark.py` file we have created. This runs a wordcount Map Reduce using PySpark. The script only takes 1 input:

- The file path + name (e.g. /root/home/pg4300.txt)

## `linux_count_words.sh`

Allows us to run the wordcount program using linux commands. The script takes 2 inputs:

- The input file path (e.g. /root/home/pg4300.txt)
- The output file path (e.g. /root/output/pg4300_1.txt)

## To run the commands, you must first source the script itself:

```bash
source ./scripts/setup_functions.sh && hadoop_standalone && hadoop_wordcount_example
```