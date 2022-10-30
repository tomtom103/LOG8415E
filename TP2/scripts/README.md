# Scripts

This directory contains scripts used for the development of the project.

## `configure_instance.sh`

This script is called inside every container to install all required dependencies

## `setup_functions.sh`

Allows us to create different functions which can then be called by the Makefile file.

To run the commands, you must first source the script itself:

```bash
source ./scripts/setup_functions.sh && hadoop_standalone && hadoop_wordcount dataset0.txt
```