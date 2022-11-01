#!/bin/bash

set -e

scp -i ./labuser.pem -r ubuntu@ec2-3-219-167-24.compute-1.amazonaws.com:/home/shared/out/ ./