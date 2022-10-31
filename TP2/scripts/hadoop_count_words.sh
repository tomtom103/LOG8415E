#!/bin/bash 

# Run the word count with hadoop
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar wordcount input/$1 output/"${2}_${3}" &> /dev/null
