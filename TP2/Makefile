SHELL := /bin/bash


.PHONY: hadoop_vs_linux
hadoop_vs_linux:
	source ./scripts/setup_functions.sh && \
		hadoop_standalone && hadoop_wordcount pg4300.txt && \
		linux_wordcount ./files/pg4300.txt

.PHONY: hadoop_vs_spark
hadoop_vs_spark:
	echo "Hello World!"

.PHONY: recommendation
recommendation:
	source ./scripts/setup_functions.sh && \
		hadoop_standalone && hadoop_recommendation