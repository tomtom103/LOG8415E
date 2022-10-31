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

function hadoop_wordcount_example() {
    pprint "COUNTING WORDS IN HADOOP STANDALONE MODE"
    hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar \
    wordcount input/pg4300.txt output/pg4300
    pprint "FINISHED COUNTING WORDS WITH HADOOP"
    pprint "START OF OUTPUT:"
    hdfs dfs -cat output/pg4300/part-r-00000 | tail -n 10
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

function hadoop_wordcount() {
    pprint "RUNNING WORDCOUNT ON ALL FILES WITH HADOOP"
    FILES=$(ls /root/files | grep dataset)
    for file in $FILES;
    do
        FILENAME_NO_EXT=$(echo "$file" | cut -f 1 -d '.')
        for i in $(seq 1 3);
        do
            TIME_TAKEN=$(/usr/bin/time -f '%E' ./scripts/hadoop_count_words.sh $file $FILENAME_NO_EXT $i 2>&1)
            echo "Filename:$file time:$TIME_TAKEN" >> /root/out/hadoop.txt 
            pprint "OUTPUT OF output/$FILENAME_NO_EXT\_$i"
            hdfs dfs -cat output/${FILENAME_NO_EXT}_$i/part-r-00000 | tail -n 10
        done;
    done;

}

function spark_wordcount() {
    pprint "RUNNING WORDCOUNT ON ALL FILES WITH PYSPARK"
    cd /root/scripts
    pprint "ACTIVATING VENV"
    source /root/.venv/bin/activate
    mkdir -p /root/output
    FILES=$(ls /root/files | grep dataset)
    for file in $FILES;
    do
        FILENAME_NO_EXT=$(echo "$file" | cut -f 1 -d '.')
        for i in $(seq 1 3);
        do
            TIME_TAKEN=$(/usr/bin/time -f '%E' ./spark_count_words.sh /root/files/$file 2>&1)
            echo "Filename:$file time:$TIME_TAKEN" >> /root/out/spark.txt
            pprint "OUTPUT OF $file $i / 3"
            cat /root/output/$FILENAME_NO_EXT\_output_spark.txt | tail -n 10
        done;
    done;
}


function hadoop_recommendation() {
    pprint "RUNNING RECOMMENDATION"
    hadoop jar /root/RecommendationMR/recommendation.jar Recommendation input/soc-LiveJournal1Adj.txt output/result
    pprint "FINISHED RUNNING RECOMMENDATION"
}

function run_metrics() {
    pprint "RUNNING METRICS"
}