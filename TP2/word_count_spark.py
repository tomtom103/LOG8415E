from pyspark.sql import SparkSession
import sys

#start a spark session
session= SparkSession.builder.getOrCreate()

#Initialize the context
spark = session.sparkContext

#read the file from the path sent from the command line
file = spark.textFile(sys.argv[1])

#Map : emitting each word with a value of one
wordList = file.flatMap(lambda l: l.split(" ")).map(lambda w : (w,1))

#Reduce : summing the count for each word
count = wordList.reduceByKey(lambda w1,w2: w1+w2).collect()

#print 
for w in count :
    print(w)



