SHELL := /bin/bash

.PHONY: setup
setup:
	source ./scripts/setup_functions.sh && \
		hadoop_standalone

.PHONY: hadoop_vs_linux
hadoop_vs_linux:
	source ./scripts/setup_functions.sh && \
		hadoop_wordcount_example pg4300.txt && \
		linux_wordcount ./files/pg4300.txt

.PHONY: hadoop_vs_spark
hadoop_vs_spark:
	source ./scripts/setup_functions.sh && \
		hadoop_wordcount && spark_wordcount

.PHONY: metrics
metrics:
	source ./scripts/setup_functions.sh && \
		source /root/.venv/bin/activate && \
		cd /root/scripts && python3 plot.py

.PHONY: recommendation
recommendation:
	source ./scripts/setup_functions.sh && \
		hadoop_recommendation