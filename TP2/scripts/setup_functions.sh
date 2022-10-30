HADOOP_HOME=/usr/local/hadoop-3.3.4

RED='\033[0;31m'
NC='\033[0m'

function pprint() {
    echo -e "${RED} $1 ${NC}"
}

function hadoop_standalone() {
    pprint "HADOOP SETUP STANDALONE MODE"
    cp ./configs/core-site.xml $HADOOP_HOME/etc/hadoop/
    cp ./configs/hdfs-site.xml $HADOOP_HOME/etc/hadoop/
    pprint "CREATING HDFS DIRECTORY"
    hdfs dfs -mkdir -p input > /dev/null 2>&1
    hdfs dfs -mkdir -p output > /dev/null 2>&1
    pprint "ADDING LOCAL FILES FOLDER TO HADOOP DIRECTORY"
    hdfs dfs -copyFromLocal files/* input > /dev/null 2>&1
}

function hadoop_wordcount() {
    FILENAME_NO_EXT=$(echo "$1" | cut -f 1 -d '.')
    pprint "COUNTING WORDS IN HADOOP STANDALONE MODE"
    pprint "TIME TAKEN: "
    time hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar \
    wordcount input/$1 output/$FILENAME_NO_EXT > /dev/null 2>&1
    pprint "FINISHED COUNTING WORDS WITH HADOOP"
    pprint "START OF OUTPUT:"
    hdfs dfs -cat output/$FILENAME_NO_EXT/part-r-00000 | tail -n 10
}

function linux_wordcount() {
    pprint "COUNTING WORDS WITH LINUX"
    mkdir -p ./out
    pprint "START OF OUTPUT:"
    # NR = Number of lines seen so far
    # RC = Record separator
    # The awk command allows us to separate the words into their own line
    cat $1 | awk 'NR>1' RS=' ' | sort | uniq -c | tail -n 10
}

function spark_wordcount() {
    pprint "COUNTING WORDS WITH SPARK"
    
}