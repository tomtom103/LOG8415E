from pyspark.sql import SparkSession
from pathlib import Path
import sys

current_path = Path(__file__).parent.absolute()

path = sys.argv[1]
input_file_name = path.split('/')[-1]

#start a spark session
session = SparkSession.builder.getOrCreate()

#Initialize the context
spark = session.sparkContext

#read the file from the path sent from the command line
file = spark.textFile(path)

#Map : emitting each word with a value of one
wordList = file.flatMap(lambda l: l.split(" ")).map(lambda w : (w,1))

#Reduce : summing the count for each word
count = wordList.reduceByKey(lambda c1,c2: c1+c2)

#print the words with their count in output file
with open(f'../output/{input_file_name.split(".")[0]}_output_spark.txt', 'w') as f:
    for w in count.collect():
        f.write(str(w) + '\n')


