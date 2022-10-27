export HADOOP_PREFIX=/usr/local/hadoop-2.10.1

RED='\033[0;31m'
NC='\033[0m'

function pprint() {
    echo -e "${RED} $1 ${NC}"
}

pprint "Setup Standalone mode"
cp ./configs/core-site.xml $HADOOP_PREFIX/etc/hadoop/
cp ./configs/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/
pprint "Setup Standalone mode Done"

pprint "Creating directory"
hdfs dfs -mkdir -p input &>/dev/null
pprint "Copy local files from hadoop directory"
hdfs dfs -copyFromLocal files/* input &>/dev/null

pprint "COUNT WORDS IN STANDALONE MODE"
# TODO: Figure out how the fuck to get real time...
time -v $(hadoop jar $HADOOP_PREFIX/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.10.1.jar \
    wordcount input/pg4300.txt output/pg4300)
# pprint "Showing 10 outputs"
# hdfs dfs -cat output/pg4300/part-r-00000
# pprint "Finished counting words!"

pprint "Stopping HADOOP Node"
$HADOOP_PREFIX/sbin/stop-dfs.sh &> /dev/null