#!/bin/bash

set -e

cat $1 | awk 'NR>1' RS=' ' | sort | uniq -c > $2
