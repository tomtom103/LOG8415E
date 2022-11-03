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
    # Creating needed directories
    hdfs dfs -mkdir -p input > /dev/null 2>&1
    hdfs dfs -mkdir -p output > /dev/null 2>&1
    pprint "ADDING LOCAL FILES FOLDER TO HADOOP DIRECTORY"
    # Adding locally stored files to dfs folder
    hdfs dfs -copyFromLocal files/* input > /dev/null 2>&1
}

function hadoop_wordcount_example() {
    pprint "COUNTING WORDS IN HADOOP STANDALONE MODE"
    # Run the hadoop wordcount with the example file
    hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.4.jar \
    wordcount input/pg4300.txt output/pg4300
    pprint "FINISHED COUNTING WORDS WITH HADOOP"
    pprint "START OF OUTPUT:"
    # Print the last 10 lines of the output
    hdfs dfs -cat output/pg4300/part-r-00000 | tail -n 10
}

function linux_wordcount_example() {
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
    # List all files that we need
    FILES=$(ls /root/files | grep dataset)
    for file in $FILES;
    do
        # Get the file name without file extensions
        FILENAME_NO_EXT=$(echo "$file" | cut -f 1 -d '.')
        for i in $(seq 1 3);
        do
            # Run the hadoop wordcount
            TIME_TAKEN=$(/usr/bin/time -f '%E' ./scripts/hadoop_count_words.sh $file $FILENAME_NO_EXT $i 2>&1)
            # Save filename and time taken to a file
            echo "Filename:$file time:$TIME_TAKEN" >> /root/out/hadoop.txt 
            pprint "OUTPUT OF output/$FILENAME_NO_EXT\_$i"
            # Print the last 10 rows of the output
            hdfs dfs -cat output/${FILENAME_NO_EXT}_$i/part-r-00000 | tail -n 10
        done;
    done;

}

function spark_wordcount() {
    pprint "RUNNING WORDCOUNT ON ALL FILES WITH PYSPARK"
    cd /root/scripts
    pprint "ACTIVATING VENV"
    # Activating python venv
    source /root/.venv/bin/activate
    # Make sure output dir exists
    mkdir -p /root/output
    FILES=$(ls /root/files | grep dataset)
    for file in $FILES;
    do
        # Get the filename without extension
        FILENAME_NO_EXT=$(echo "$file" | cut -f 1 -d '.')
        for i in $(seq 1 3);
        do
            # Store the time taken in this variable
            TIME_TAKEN=$(/usr/bin/time -f '%E' ./spark_count_words.sh /root/files/$file 2>&1)
            # Write out the file name + time taken
            echo "Filename:$file time:$TIME_TAKEN" >> /root/out/spark.txt
            pprint "OUTPUT OF $file $i / 3"
            # Print the last 10 rows of the output
            cat /root/output/$FILENAME_NO_EXT\_output_spark.txt | tail -n 10
        done;
    done;
}

function linux_wordcount_metrics() {
    pprint "RUNNING WORDCOUNT ON LINUX"
    mkdir -p /root/output
    for i in $(seq 1 8);
    do
        TIME_TAKEN=$(/usr/bin/time -f '%E' ./scripts/linux_count_words.sh /root/files/pg4300.txt /root/output/pg4300"_$i".txt 2>&1)
        echo "Filename:pg4300.txt time:$TIME_TAKEN" >> /root/out/linux_metrics.txt
        pprint "OUTPUT OF pg4300.txt $i / 8"
        cat /root/output/pg4300_$i.txt | tail -n 10
    done;
}

function hadoop_wordcount_metrics() {
    pprint "COUNTING WORDS IN HADOOP STANDALONE MODE"
    # Run the hadoop wordcount with the example file
    for i in $(seq 1 8);
    do
        TIME_TAKEN=$(/usr/bin/time -f '%E' ./scripts/hadoop_count_words.sh pg4300.txt pg4300 $i 2>&1)
        echo "Filename:pg4300.txt time:$TIME_TAKEN" >> /root/out/hadoop_metrics.txt
        pprint "OUTPUT OF pg4300.txt $i / 8"
        hdfs dfs -cat output/pg4300_$i/part-r-00000 | tail -n 10
    done;
}


function hadoop_recommendation() {
    pprint "RUNNING RECOMMENDATION"
    # Run the friend recommendation example
    hadoop jar /root/java/recommendation.jar Recommendation input/soc-LiveJournal1Adj.txt output/result
    pprint "FINISHED RUNNING RECOMMENDATION"
}

function fetch_recommendation_ids() {
    hdfs dfs -cat output/result/part-r-00000 > /root/out/friend_recommendation.txt || echo "No output found, run hadoop_recommendation first"
    ids=(924 8941 8942 9019 9020 9021 9022 9990 9992 9993)
    for id in "${ids[@]}";
    do
        echo "ID: ${id}"
        grep -P "^${id}[ \t]" /root/out/friend_recommendation.txt >> /root/out/friend_recommendation_filtered.txt
    done;
}